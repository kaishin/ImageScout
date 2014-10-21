import QuartzCore

enum ScoutedImageType: String {
  case GIF = "gif"
  case PNG = "png"
  case JPEG = "jpeg"
  case Unsupported = "unsupported"
}

typealias ScoutCompletionBlock = (NSError?, CGSize, ScoutedImageType) -> ()

let unsupportedFormatErrorMessage = "Unsupported image format. ImageScout only supports PNG, GIF, and JPEG."
let unableToParseErrorMessage = "Scouting operation failed. The remote image is likely malformated or corrupt."
let invalidURIErrorMessage = "Invalid URI parameter."

let errorDomain = "ImageScoutErrorDomain"

class ImageScout {
  private var session: NSURLSession
  private var sessionDelegate = SessionDelegate()
  private var queue = NSOperationQueue()
  private var operations = [String : ScoutOperation]()
  
  init() {
    let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    session = NSURLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil)
    sessionDelegate.scout = self
  }

  /// Takes a URL string and a completion block and returns void.
  /// The completion block takes an optional error, a size, and an image type,
  /// and returns void.
  
  func scoutImageWithURI(URI: String, completion: ScoutCompletionBlock) {
    if let unwrappedURL = NSURL(string: URI) {
      let operation = ScoutOperation(task: session.dataTaskWithURL(unwrappedURL))

      operation.completionBlock = {
        completion(operation.error, operation.size, operation.type)
        self.operations[URI] = nil
      }

      addOperation(operation, withURI: URI)
    } else {
      let URLError = ImageScout.error(invalidURIErrorMessage, code: 100)
      completion(URLError, CGSizeZero, ScoutedImageType.Unsupported)
    }
  }

  // MARK: Delegate Methods

  func didReceiveData(data: NSData, task: NSURLSessionDataTask) {
    if let requestURL = task.currentRequest.URL.absoluteString {
      if let operation = operations[requestURL] {
        operation.appendData(data)
      }
    }
  }

  func didCompleteWithError(error: NSError?, task: NSURLSessionDataTask) {
    if let requestURL = task.currentRequest.URL.absoluteString {
      let completionError = error ?? ImageScout.error(unableToParseErrorMessage, code: 101)

      if let operation = operations[requestURL] {
        operation.terminateWithError(completionError)
      }
    }
  }

  // MARK: Private Methods

  private func addOperation(operation: ScoutOperation, withURI URI: String) {
    operations[URI] = operation
    queue.addOperation(operation)
  }

  // MARK: Class Methods

  class func error(message: String, code: Int) -> NSError {
    return NSError(domain: errorDomain, code:code, userInfo:[NSLocalizedDescriptionKey: message])
  }

  // MARK: - Delegate
  
  private class SessionDelegate: NSObject, NSURLSessionDataDelegate  {
    var scout: ImageScout?
    
    private func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
      if let unwrappedScout = scout {
        unwrappedScout.didReceiveData(data, task: dataTask)
      }
    }

    private func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
      if let unwrappedScout = scout {
        unwrappedScout.didCompleteWithError(error, task: task as NSURLSessionDataTask)
      }
    }
  }

  // MARK: - Operation
  
  private class ScoutOperation: NSOperation {
    var size = CGSizeZero
    var type = ScoutedImageType.Unsupported
    var error: NSError?
    var mutableData = NSMutableData()
    var dataTask: NSURLSessionDataTask

    init(task: NSURLSessionDataTask) {
      dataTask = task
    }
    
    private override func start() {
      if !cancelled { dataTask.resume() }
    }
    
    func appendData(data: NSData) {
      if !cancelled { mutableData.appendData(data) }
      if (data.length < 2) { return }
      
      if !cancelled {
        parse()
      }
    }

    func terminateWithError(completionError: NSError) {
      error = ImageScout.error(invalidURIErrorMessage, code: 100)
      complete()
    }

    private func parse() {
      let dataCopy = mutableData.copy() as NSData
      type = Parser.imageTypeFromData(dataCopy)
      
      if (type != .Unsupported) {
        size = Parser.imageSizeFromData(dataCopy)
        if (size != CGSizeZero) { complete() }
      } else if dataCopy.length > 2 {
        self.error = ImageScout.error(unsupportedFormatErrorMessage, code: 102)
        complete()
      }
    }

    private func complete() {
      completionBlock!()
      self.cancel()
    }
    
    private override func cancel() {
      super.cancel()
      dataTask.cancel()
    }
  }

  // MARK: - Parser
  
  struct Parser {
    private enum JPEGHeaderSegment {
      case NextSegment, SOFSegment, SkipSegment, ParseSegment, EOISegment
    }
    
    private struct PNGSize {
      var width: UInt32 = 0
      var height: UInt32 = 0
    }
    
    private struct GIFSize {
      var width: UInt16 = 0
      var height: UInt16 = 0
    }
    
    private struct JPEGSize {
      var height: UInt16 = 0
      var width: UInt16 = 0
    }

    /// Takes an NSData instance and returns an image type.
    static func imageTypeFromData(data: NSData) -> ScoutedImageType {
      let sampleLength = 2
      
      if (data.length < sampleLength) { return .Unsupported }
      
      var length = UInt16(0); data.getBytes(&length, range: NSRange(location: 0, length: sampleLength))
      
      switch CFSwapInt16(length) {
      case 0xFFD8:
        return .JPEG
      case 0x8950:
        return .PNG
      case 0x4749:
        return .GIF
      default:
        return .Unsupported
      }
    }
    
    /// Takes an NSData instance and returns an image size (CGSize).
    static func imageSizeFromData(data: NSData) -> CGSize {
      switch self.imageTypeFromData(data) {
      case .PNG:
        return self.PNGSizeFromData(data)
      case .GIF:
        return self.GIFSizeFromData(data)
      case .JPEG:
        return self.JPEGSizeFromData(data)
      default:
        return CGSizeZero
      }
    }

    // MARK: PNG

    static func PNGSizeFromData(data: NSData) -> CGSize {
      if (data.length < 25) { return CGSizeZero }
      
      var size = PNGSize(); data.getBytes(&size, range: NSRange(location: 16, length: 8))
      
      return CGSize(width: Int(CFSwapInt32(size.width)), height: Int(CFSwapInt32(size.height)))
    }

    // MARK: GIF

    static func GIFSizeFromData(data: NSData) -> CGSize {
      if (data.length < 11) { return CGSizeZero }
      
      var size = GIFSize(); data.getBytes(&size, range: NSRange(location: 6, length: 4))
      
      return CGSize(width: Int(size.width), height: Int(size.height))
    }

    // MARK: JPEG
    
    static func JPEGSizeFromData(data: NSData) -> CGSize {
      var offset = 2
      var size: CGSize?
      
      do {
        if (data.length <= offset) { size = CGSizeZero }
        size = self.parseJPEGData(data, offset: offset, segment: .NextSegment)
      } while size == nil
      
      return size!
    }
    
    private static func parseJPEGData(data: NSData, offset: Int, segment: JPEGHeaderSegment) -> CGSize {
      if segment == .EOISegment
        || (data.length <= offset + 1)
        || (data.length <= offset + 2) && segment == .SkipSegment
        || (data.length <= offset + 7) && segment == .ParseSegment {
          return CGSizeZero
      }
      
      switch segment {
      case .NextSegment:
        let newOffset = offset + 1
        var byte = 0x0; data.getBytes(&byte, range: NSRange(location: newOffset, length: 1))
        
        if byte == 0xFF {
          return self.parseJPEGData(data, offset: newOffset, segment: .SOFSegment)
        } else {
          return self.parseJPEGData(data, offset: newOffset, segment: .NextSegment)
        }
        
      case .SOFSegment:
        let newOffset = offset + 1
        var byte = 0x0; data.getBytes(&byte, range: NSRange(location: newOffset, length: 1))
        
        switch byte {
        case 0xE0...0xEF:
          return self.parseJPEGData(data, offset: newOffset, segment: .SkipSegment)
        case 0xC0...0xC3, 0xC5...0xC7, 0xC9...0xCB, 0xCD...0xCF:
          return self.parseJPEGData(data, offset: newOffset, segment: .ParseSegment)
        case 0xFF:
          return self.parseJPEGData(data, offset: newOffset, segment: .SOFSegment)
        case 0xD9:
          return self.parseJPEGData(data, offset: newOffset, segment: .EOISegment)
        default:
          return self.parseJPEGData(data, offset: newOffset, segment: .SkipSegment)
        }
        
      case .SkipSegment:
        var length = UInt16(0)
        data.getBytes(&length, range: NSRange(location: offset + 1, length: 2))
        
        let newOffset = offset + CFSwapInt16(length) - 1
        return self.parseJPEGData(data, offset: Int(newOffset), segment: .NextSegment)
        
      case .ParseSegment:
        var size = JPEGSize(); data.getBytes(&size, range: NSRange(location: offset + 4, length: 4))
        return CGSize(width: Int(CFSwapInt16(size.width)), height: Int(CFSwapInt16(size.height)))
        
      default:
        return CGSizeZero
      }
    }
  }
}
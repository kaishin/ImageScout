import QuartzCore

public enum ScoutedImageType: String {
  case GIF
  case PNG
  case JPEG
  case Unsupported
}

public typealias ScoutCompletionBlock = (NSError?, CGSize, ScoutedImageType) -> ()

let unsupportedFormatErrorMessage = "Unsupported image format. ImageScout only supports PNG, GIF, and JPEG."
let unableToParseErrorMessage = "Scouting operation failed. The remote image is likely malformated or corrupt."

let errorDomain = "ImageScoutErrorDomain"

public class ImageScout {
  private var session: NSURLSession
  private var sessionDelegate = SessionDelegate()
  private var queue = NSOperationQueue()
  private var operations = [String : ScoutOperation]()
  
  public init() {
    let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
    session = NSURLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil)
    sessionDelegate.scout = self
  }

  /// Takes an `NSURL` and a completion block.
  /// The completion block takes an optional error, a size, and an image type,
  /// and returns void.
  
  public func scoutImageWithURL(URL: NSURL, completion: ScoutCompletionBlock) {
    let operation = ScoutOperation(task: session.dataTaskWithURL(URL))
    operation.completionBlock = { [unowned self] in
      completion(operation.error, operation.size, operation.type)
      self.operations[URL.absoluteString] = nil
    }

    addOperation(operation, withURI: URL.absoluteString)
  }

  // MARK: - Private Methods

  private func addOperation(operation: ScoutOperation, withURI URI: String) {
    operations[URI] = operation
    queue.addOperation(operation)
  }

  // MARK: - Class Methods

  class func error(message: String, code: Int) -> NSError {
    return NSError(domain: errorDomain, code:code, userInfo:[NSLocalizedDescriptionKey: message])
  }
}

extension ImageScout {
  func didReceiveData(data: NSData, task: NSURLSessionDataTask) {
    guard let requestURL = task.currentRequest?.URL?.absoluteString else { return }
    guard let operation = operations[requestURL] else { return }

    operation.appendData(data)
  }

  func didCompleteWithError(error: NSError?, task: NSURLSessionDataTask) {
    guard let requestURL = task.currentRequest?.URL?.absoluteString,
      let operation = operations[requestURL]
      else { return }

    let completionError = error ?? ImageScout.error(unableToParseErrorMessage, code: 101)
    operation.terminateWithError(completionError)
  }
}
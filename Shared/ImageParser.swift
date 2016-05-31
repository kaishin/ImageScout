import QuartzCore

struct ImageParser {
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
    
    var size = PNGSize()
    data.getBytes(&size, range: NSRange(location: 16, length: 8))
    
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
    let offset = 2
    var size: CGSize?
    
    repeat {
      if (data.length <= offset) { size = CGSizeZero }
      size = self.parseJPEGData(data, offset: offset, segment: .NextSegment)
    } while size == nil
    
    return size!
  }
  private typealias JPEGParseTuple = (data: NSData, offset: Int, segment: JPEGHeaderSegment)

  private enum JPEGParseResult {
    case Size(CGSize)
    case Tuple(JPEGParseTuple)
  }

  private static func parseJPEG(tuple: JPEGParseTuple) -> JPEGParseResult {
    let data = tuple.data
    let offset = tuple.offset
    let segment = tuple.segment

    if segment == .EOISegment
      || (data.length <= offset + 1)
      || (data.length <= offset + 2) && segment == .SkipSegment
      || (data.length <= offset + 7) && segment == .ParseSegment {
        return .Size(CGSizeZero)
    }
    switch segment {
    case .NextSegment:
      let newOffset = offset + 1
      var byte = 0x0; data.getBytes(&byte, range: NSRange(location: newOffset, length: 1))

      if byte == 0xFF {
        return .Tuple(JPEGParseTuple(data, offset: newOffset, segment: .SOFSegment))
      } else {
        return .Tuple(JPEGParseTuple(data, offset: newOffset, segment: .NextSegment))
      }
    case .SOFSegment:
      let newOffset = offset + 1
      var byte = 0x0; data.getBytes(&byte, range: NSRange(location: newOffset, length: 1))

      switch byte {
      case 0xE0...0xEF:
        return .Tuple(JPEGParseTuple(data, offset: newOffset, segment: .SkipSegment))
      case 0xC0...0xC3, 0xC5...0xC7, 0xC9...0xCB, 0xCD...0xCF:
        return .Tuple(JPEGParseTuple(data, offset: newOffset, segment: .ParseSegment))
      case 0xFF:
        return .Tuple(JPEGParseTuple(data, offset: newOffset, segment: .SOFSegment))
      case 0xD9:
        return .Tuple(JPEGParseTuple(data, offset: newOffset, segment: .EOISegment))
      default:
        return .Tuple(JPEGParseTuple(data, offset: newOffset, segment: .SkipSegment))
      }

    case .SkipSegment:
      var length = UInt16(0)
      data.getBytes(&length, range: NSRange(location: offset + 1, length: 2))

      let newOffset = offset + Int(CFSwapInt16(length)) - 1
      return .Tuple(JPEGParseTuple(data, offset: Int(newOffset), segment: .NextSegment))

    case .ParseSegment:
      var size = JPEGSize(); data.getBytes(&size, range: NSRange(location: offset + 4, length: 4))
      return .Size(CGSize(width: Int(CFSwapInt16(size.width)), height: Int(CFSwapInt16(size.height))))
    default:
      return .Size(CGSizeZero)
    }
  }

  private static func parseJPEGData(data: NSData, offset: Int, segment: JPEGHeaderSegment) -> CGSize {
    var tuple: JPEGParseResult = .Tuple(JPEGParseTuple(data, offset: offset, segment: segment))
    while true {
      switch tuple {
      case .Size(let size):
        return size
      case .Tuple(let newTuple):
        tuple = parseJPEG(newTuple)
      }
    }
  }
}

import QuartzCore

struct ImageParser {
  private enum JPEGHeaderSegment {
    case nextSegment, sofSegment, skipSegment, parseSegment, eoiSegment
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
  static func imageType(with data: Data) -> ScoutedImageType {
    let sampleLength = 2
    
    if (data.count < sampleLength) { return .unsupported }
    
    var length = UInt16(0); (data as NSData).getBytes(&length, range: NSRange(location: 0, length: sampleLength))
    
    switch CFSwapInt16(length) {
    case 0xFFD8:
      return .jpeg
    case 0x8950:
      return .png
    case 0x4749:
      return .gif
    default:
      return .unsupported
    }
  }
  
  /// Takes an NSData instance and returns an image size (CGSize).
  static func imageSize(with data: Data) -> CGSize {
    switch self.imageType(with: data) {
    case .png:
      return self.sizeForPNG(with: data)
    case .gif:
      return self.sizeForGIF(with: data)
    case .jpeg:
      return self.sizeForJPEG(with: data)
    default:
      return CGSize.zero
    }
  }
  
  // MARK: PNG
  
  static func sizeForPNG(with data: Data) -> CGSize {
    if (data.count < 25) { return CGSize.zero }
    
    var size = PNGSize()
    (data as NSData).getBytes(&size, range: NSRange(location: 16, length: 8))
    
    return CGSize(width: Int(CFSwapInt32(size.width)), height: Int(CFSwapInt32(size.height)))
  }
  
  // MARK: GIF
  
  static func sizeForGIF(with data: Data) -> CGSize {
    if (data.count < 11) { return CGSize.zero }
    
    var size = GIFSize(); (data as NSData).getBytes(&size, range: NSRange(location: 6, length: 4))
    
    return CGSize(width: Int(size.width), height: Int(size.height))
  }
  
  // MARK: JPEG
  
  static func sizeForJPEG(with data: Data) -> CGSize {
    let offset = 2
    var size: CGSize?
    
    repeat {
      if (data.count <= offset) { size = CGSize.zero }
      size = self.parse(JPEGData: data, offset: offset, segment: .nextSegment)
    } while size == nil
    
    return size!
  }
  private typealias JPEGParseTuple = (data: Data, offset: Int, segment: JPEGHeaderSegment)

  private enum JPEGParseResult {
    case size(CGSize)
    case tuple(JPEGParseTuple)
  }

  private static func parse(JPEG tuple: JPEGParseTuple) -> JPEGParseResult {
    let data = tuple.data
    let offset = tuple.offset
    let segment = tuple.segment

    if segment == .eoiSegment
      || (data.count <= offset + 1)
      || (data.count <= offset + 2) && segment == .skipSegment
      || (data.count <= offset + 7) && segment == .parseSegment {
        return .size(CGSize.zero)
    }
    switch segment {
    case .nextSegment:
      let newOffset = offset + 1
      var byte = 0x0; (data as NSData).getBytes(&byte, range: NSRange(location: newOffset, length: 1))

      if byte == 0xFF {
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .sofSegment))
      } else {
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .nextSegment))
      }
    case .sofSegment:
      let newOffset = offset + 1
      var byte = 0x0; (data as NSData).getBytes(&byte, range: NSRange(location: newOffset, length: 1))

      switch byte {
      case 0xE0...0xEF:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .skipSegment))
      case 0xC0...0xC3, 0xC5...0xC7, 0xC9...0xCB, 0xCD...0xCF:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .parseSegment))
      case 0xFF:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .sofSegment))
      case 0xD9:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .eoiSegment))
      default:
        return .tuple(JPEGParseTuple(data, offset: newOffset, segment: .skipSegment))
      }

    case .skipSegment:
      var length = UInt16(0)
      (data as NSData).getBytes(&length, range: NSRange(location: offset + 1, length: 2))

      let newOffset = offset + Int(CFSwapInt16(length)) - 1
      return .tuple(JPEGParseTuple(data, offset: Int(newOffset), segment: .nextSegment))

    case .parseSegment:
      var size = JPEGSize(); (data as NSData).getBytes(&size, range: NSRange(location: offset + 4, length: 4))
      return .size(CGSize(width: Int(CFSwapInt16(size.width)), height: Int(CFSwapInt16(size.height))))
    default:
      return .size(CGSize.zero)
    }
  }

  private static func parse(JPEGData data: Data, offset: Int, segment: JPEGHeaderSegment) -> CGSize {
    var tuple: JPEGParseResult = .tuple(JPEGParseTuple(data, offset: offset, segment: segment))
    while true {
      switch tuple {
      case .size(let size):
        return size
      case .tuple(let newTuple):
        tuple = parse(JPEG: newTuple)
      }
    }
  }
}

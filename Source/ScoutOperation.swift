import QuartzCore

class ScoutOperation: NSOperation {
  var size = CGSizeZero
  var type = ScoutedImageType.Unsupported
  var error: NSError?
  var mutableData = NSMutableData()
  var dataTask: NSURLSessionDataTask
  
  init(task: NSURLSessionDataTask) {
    dataTask = task
  }
  
  override func start() {
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
    error = completionError
    complete()
  }
  
  private func parse() {
    let dataCopy = mutableData.copy() as! NSData
    type = ImageParser.imageTypeFromData(dataCopy)
    
    if (type != .Unsupported) {
      size = ImageParser.imageSizeFromData(dataCopy)
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
  
  override func cancel() {
    super.cancel()
    dataTask.cancel()
  }
}

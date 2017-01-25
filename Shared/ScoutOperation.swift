import QuartzCore

class ScoutOperation: Operation {
  var size = CGSize.zero
  var type = ScoutedImageType.unsupported
  var error: NSError?
  var mutableData = Data()
  var dataTask: URLSessionDataTask
  
  init(with task: URLSessionDataTask) {
    dataTask = task
  }
  
  override func start() {
    if !isCancelled { dataTask.resume() }
  }
  
  func append(_ data: Data) {
    if !isCancelled { mutableData.append(data) }
    if (data.count < 2) { return }
    
    if !isCancelled {
      parse()
    }
  }
  
  func terminate(with completionError: NSError) {
    error = completionError
    complete()
  }
  
  private func parse() {
    type = ImageParser.imageType(with: mutableData)
    
    if (type != .unsupported) {
      size = ImageParser.imageSize(with: mutableData)
      if (size != CGSize.zero) { complete() }
    } else if mutableData.count > 2 {
      self.error = ImageScout.error(withMessage: unsupportedFormatErrorMessage, code: 102)
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

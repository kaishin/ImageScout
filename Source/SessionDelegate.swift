import Foundation

class SessionDelegate: NSObject, NSURLSessionDataDelegate  {
  weak var scout: ImageScout?
  
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    guard let scout = scout else { return }
    scout.didReceiveData(data, task: dataTask)
  }
  
  func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    guard let scout = scout else { return }
    scout.didCompleteWithError(error, task: task as! NSURLSessionDataTask)
  }
}

import Foundation

class SessionDelegate: NSObject, NSURLSessionDataDelegate  {
  weak var scout: ImageScout?
  
  func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
    if let unwrappedScout = scout {
      unwrappedScout.didReceiveData(data, task: dataTask)
    }
  }
  
  func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
    if let unwrappedScout = scout {
      unwrappedScout.didCompleteWithError(error, task: task as! NSURLSessionDataTask)
    }
  }
}
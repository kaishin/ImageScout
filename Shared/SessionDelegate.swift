import Foundation

class SessionDelegate: NSObject, URLSessionDataDelegate {
  weak var scout: ImageScout?
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let scout = scout else { return }
    scout.didReceive(data: data, task: dataTask)
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let scout = scout else { return }
    scout.didComplete(with: error as NSError?, task: task as! URLSessionDataTask)
  }
}

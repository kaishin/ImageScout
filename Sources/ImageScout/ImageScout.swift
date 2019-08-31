import QuartzCore

/// Supported image types.
public enum ScoutedImageType: String {
  case gif
  case png
  case jpeg
  case unsupported
}

/// A scout completion block that takes an optional error, a CGSize, and a ScoutedImageType and returns nothing.
public typealias ScoutCompletionBlock = (NSError?, CGSize, ScoutedImageType) -> ()

let unsupportedFormatErrorMessage = "Unsupported image format. ImageScout only supports PNG, GIF, and JPEG."
let unableToParseErrorMessage = "Scouting operation failed. The remote image is likely malformated or corrupt."

let errorDomain = "ImageScoutErrorDomain"

/// The class you interact with in order to perform image scouting operations. You should maintain reference to an instance of this class until the callback completes. If reference is lost, your completion handler will never be executed.
public class ImageScout {
  private var session: URLSession
  private var sessionDelegate = SessionDelegate()
  private var queue = OperationQueue()
  fileprivate var operations = [String : ScoutOperation]()

  /// Creates a default `ImageScout` instance.
  public init() {
    let sessionConfig = URLSessionConfiguration.ephemeral
    session = URLSession(configuration: sessionConfig, delegate: sessionDelegate, delegateQueue: nil)
    sessionDelegate.scout = self
  }

  /// Scouts an image in a given URL.
  /// - parameter URL: The URL of the image.
  /// - parameter completion: The completion block to call once the scout operation is complete.
  public func scoutImage(atURL URL: Foundation.URL, completion: @escaping ScoutCompletionBlock) {
    let urlString: String = URL.absoluteString

    let operation = ScoutOperation(with: session.dataTask(with: URL))

    operation.completionBlock = { [weak self] in
      completion(operation.error, operation.size, operation.type)
      self?.operations[urlString] = nil
    }

    add(operation, withURI: urlString)
  }

  // MARK: - Private Methods

  private func add(_ operation: ScoutOperation, withURI URI: String) {
    operations[URI] = operation
    queue.addOperation(operation)
  }

  // MARK: - Class Methods

  class func error(withMessage message: String, code: Int) -> NSError {
    return NSError(domain: errorDomain, code:code, userInfo:[NSLocalizedDescriptionKey: message])
  }
}

extension ImageScout {
  func didReceive(data: Data, task: URLSessionDataTask) {
    guard let requestURL = task.currentRequest?.url?.absoluteString else { return }
    guard let operation = operations[requestURL] else { return }

    operation.append(data)
  }

  func didComplete(with error: NSError?, task: URLSessionDataTask) {
    guard let requestURL = task.currentRequest?.url?.absoluteString,
      let operation = operations[requestURL]
      else { return }

    let completionError = error ?? ImageScout.error(withMessage: unableToParseErrorMessage, code: 101)
    operation.terminate(with: completionError)
  }
}

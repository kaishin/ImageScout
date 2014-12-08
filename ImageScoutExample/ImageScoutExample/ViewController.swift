import UIKit
import ImageScout

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let scout = ImageScout()
    let path = NSBundle.mainBundle().URLForResource("scout", withExtension: "gif")

    scout.scoutImageWithURI(path!.absoluteString!) { (error, size, type) -> () in
      if let unwrappedError = error {
        println("\(unwrappedError.domain)")
      } else {
        println("\(size) and \(type.rawValue)")
      }
    }
  }
}
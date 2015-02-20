import UIKit
import ImageScout

class ViewController: UIViewController {
  let scout = ImageScout()
  let jpgPath = NSBundle.mainBundle().URLForResource("scout", withExtension: "jpg")
  let pngPath = NSBundle.mainBundle().URLForResource("scout", withExtension: "png")
  let gifPath = NSBundle.mainBundle().URLForResource("scout", withExtension: "gif")

  @IBOutlet weak var jpgLabel: UILabel!
  @IBOutlet weak var pngLabel: UILabel!
  @IBOutlet weak var gifLabel: UILabel!

  override func viewDidLoad() {
    scoutImageWithPath(jpgPath!, label: jpgLabel)
    scoutImageWithPath(pngPath!, label: pngLabel)
    scoutImageWithPath(gifPath!, label: gifLabel)

    super.viewDidLoad()
  }

  private func scoutImageWithPath(path: NSURL, label: UILabel) -> () {
    scout.scoutImageWithURI(path.absoluteString!) { error, size, type in
      onMain { label.text = "\(Int(size.width))x\(Int(size.height)), \(type.rawValue.uppercaseString)" }
    }
  }
}

func onMain(block: dispatch_block_t) {
  if NSThread.isMainThread() {
    block()
  } else {
    dispatch_async(dispatch_get_main_queue(), block)
  }
}


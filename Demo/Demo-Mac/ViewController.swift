import Cocoa
import ImageScout

class ViewController: NSViewController {
  let scout = ImageScout()
  let jpgPath = NSBundle.mainBundle().URLForResource("scout", withExtension: "jpg")
  let pngPath = NSBundle.mainBundle().URLForResource("scout", withExtension: "png")
  let gifPath = NSBundle.mainBundle().URLForResource("scout", withExtension: "gif")

  @IBOutlet weak var jpgLabel: NSTextField!
  @IBOutlet weak var pngLabel: NSTextField!
  @IBOutlet weak var gifLabel: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    scoutImageWithPath(jpgPath!, label: jpgLabel)
    scoutImageWithPath(pngPath!, label: pngLabel)
    scoutImageWithPath(gifPath!, label: gifLabel)
  }

  private func scoutImageWithPath(path: NSURL, label: NSTextField) -> () {
    scout.scoutImageWithURL(path) { error, size, type in
      onMain { label.stringValue = "\(Int(size.width))x\(Int(size.height)), \(type.rawValue.uppercaseString)" }
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
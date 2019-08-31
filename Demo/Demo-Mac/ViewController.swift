import Cocoa
import ImageScout

class ViewController: NSViewController {
  let scout = ImageScout()
  let jpgPath = Bundle.main.url(forResource: "scout", withExtension: "jpg")
  let pngPath = Bundle.main.url(forResource: "scout", withExtension: "png")
  let gifPath = Bundle.main.url(forResource: "scout", withExtension: "gif")

  @IBOutlet weak var jpgLabel: NSTextField!
  @IBOutlet weak var pngLabel: NSTextField!
  @IBOutlet weak var gifLabel: NSTextField!

  override func viewDidLoad() {
    super.viewDidLoad()

    scoutImage(with: jpgPath!, label: jpgLabel)
    scoutImage(with: pngPath!, label: pngLabel)
    scoutImage(with: gifPath!, label: gifLabel)
  }

  private func scoutImage(with URL: Foundation.URL, label: NSTextField) -> () {
    scout.scoutImage(atURL: URL) { error, size, type in
      DispatchQueue.main.async { label.stringValue = "\(Int(size.width))x\(Int(size.height)), \(type.rawValue.uppercased())" }
    }
  }
}

import UIKit
import ImageScout

class ViewController: UIViewController {
  let scout = ImageScout()
  let jpgPath = Bundle.main().urlForResource("scout", withExtension: "jpg")
  let pngPath = Bundle.main().urlForResource("scout", withExtension: "png")
  let gifPath = Bundle.main().urlForResource("scout", withExtension: "gif")

  @IBOutlet weak var jpgLabel: UILabel!
  @IBOutlet weak var pngLabel: UILabel!
  @IBOutlet weak var gifLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    scoutImage(with: jpgPath!, label: jpgLabel)
    scoutImage(with: pngPath!, label: pngLabel)
    scoutImage(with: gifPath!, label: gifLabel)
  }

  private func scoutImage(with URL: Foundation.URL, label: UILabel) -> () {
    scout.scoutImage(atURL: URL) { error, size, type in
      DispatchQueue.main.async { label.text = "\(Int(size.width))x\(Int(size.height)), \(type.rawValue.uppercased())" }
    }
  }
}

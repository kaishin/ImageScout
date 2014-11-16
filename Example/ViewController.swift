import UIKit

class ViewController: UIViewController {
    
    let scout = ImageScout()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
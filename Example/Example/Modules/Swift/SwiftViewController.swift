import UIKit
import Faro

class Posts: Mappable {

    required init(json: AnyObject) {

    }

}

class SwiftViewController: UIViewController {
    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let bar = ExampleBar()
        let order = Order(path: "posts")

        bar.serve(order) { (result: Result <Posts>) in
            switch result {
            case .Model(let model):
                print("🎉 \(model)")
            default:
                print("💣 fail")
            }
        }
    }

}

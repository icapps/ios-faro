import UIKit
import Faro

class SwiftViewController: UIViewController {

    @IBOutlet var label: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let bar = Bar(configuration: Configuration(baseURL: "http://www.somplaceNice.com")) //TODO: go to a real server, for now we mock all the requests

        bar.serve(Order(path: "model")) { (result : Result <Model>) in
            switch result {
            case .Model(let model):
                self.label.text = model.value
            default:
                print("💣 damn should not happen")
            }
        }
    }
}


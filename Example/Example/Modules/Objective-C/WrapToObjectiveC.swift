import Foundation
import Faro

///This class is used to bridge to swift generic classes.
class WrapToObjectiveC: NSObject {

    func serve(success: (model: Model)->(), failure: ()->()) {
        let bar = Bar(configuration: Configuration(baseURL: "http://www.somplaceNice.com")) //TODO: go to a real server, for now we mock all the requests

        bar.serve(Order(path: "model")) { (result : Result <Model>) in
            switch result {
            case .Model(model: let internalModel):
                success(model:internalModel)
            default:
                failure()
            }
        }
    }
}
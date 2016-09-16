import Faro

/// Example model
class Model: Parseable {
    var uuid: String

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }
        uuid = json["uuid"]!
    }
    
    var JSON: [String: Any]? {
        return nil
    }
}

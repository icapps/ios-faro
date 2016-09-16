import Faro

/// Example model
class Model: Parseable {

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }
        value = json["key"]!
    }
    
    var JSON: [String: Any]? {
        return nil
    }
}

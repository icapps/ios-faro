import Faro

/// Example model
class Model: Parseable {
    var uuid: String

    var mappers: [String: ((Any?) -> ())] {
        return ["uuid": {value in self.uuid <- value }]
    }

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }
        uuid = json["uuid"]!
    }
    
}

import Faro

/// Example model
class Model: Deserializable {
    var uuid: String?

    var mappers: [String: ((Any?) -> ())] {
        return ["uuid": {self.uuid <-> $0 }]
    }

    required init?(from raw: Any) {
       map(from: raw)
    }
    
}

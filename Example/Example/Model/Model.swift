import Faro

/// Example model
class Model: JSONDeserializable {
    var uuid: String?

    required init(_ raw: [String: Any]) throws {
        self.uuid |< raw["uuid"]
    }

}

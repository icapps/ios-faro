import Faro

/// Example model
class Model: Deserializable {
    var uuid: String?

    required init?(from raw: Any) {
        guard  let json = raw as? [String: Any] else {
            return nil
        }
        self.uuid |< json["uuid"]
    }

}

import Faro

class MockModel: Deserializable {
    var uuid: String?

    required init?(from raw: Any) {
        guard let json = raw as? [String: Any] else {
            print("💀 could not cast JSON: \(raw)")
            return nil
        }
        self.uuid <-> json["uuid"]
    }

}

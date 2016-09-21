import Faro

class MockModel: Deserializable {
    var uuid: String?

    required init?(from raw: Any) {
        map(from: raw)
    }
    
    var mappers: [String : ((Any?)->())]? {
        return ["uuid": {self.uuid <-> $0 }]
    }

}

import Faro

class MockService: Service {
    let mockJSON: Any

    init(mockJSON: Any) {
        self.mockJSON = mockJSON
        super.init(configuration: Configuration(baseURL: "mockService"))
    }

    override func perform<M: Deserializable>(_ call: Call, result: @escaping (Result<M>) -> ()) {
        result(handle(json: self.mockJSON, call: call))
    }

}

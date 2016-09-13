import Faro

class MockService: Service {
    let mockJSON: AnyObject

    init(mockJSON: AnyObject) {
        self.mockJSON = mockJSON
        super.init(configuration: Configuration(baseURL: "mockService"))
    }

    override func perform<M: Mappable>(call: Call, result: (Result<M>) -> ()) {
        result(.Model(M(json: mockJSON)))
    }
}
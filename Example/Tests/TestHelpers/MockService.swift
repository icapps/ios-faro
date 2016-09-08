import Faro

class MockService: Service {
    let mockJSON: AnyObject

    init(mockJSON: AnyObject) {
        self.mockJSON = mockJSON
        super.init(configuration: Configuration(baseURL: "mockService"))
    }

    override func serve<M: Mappable>(order: Order, result: (Result<M>) -> ()) {
        result(.JSON(mockJSON))
    }

}
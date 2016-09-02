
import Faro

class MockService : Service {
    let mockJSON: AnyObject

    init(mockJSON: AnyObject) {
        self.mockJSON = mockJSON
    }

    override func serve<M : Mappable>(order: Order, result: (Result<M>) -> ()) {
        result(.JSON(json: mockJSON))
    }
}
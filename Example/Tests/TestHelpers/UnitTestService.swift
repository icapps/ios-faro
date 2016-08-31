
import Faro

public class UnitTestService: JSONServeable {

    public let mockJSON: AnyObject

    public init(mockJSON: AnyObject) {
        self.mockJSON = mockJSON
    }

    public func serve(order: Order, result: (JSONResult) -> ()) {
        result(.Success(self.mockJSON))
    }

}
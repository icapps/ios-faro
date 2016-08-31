
public class UnitTestService <U>: Serveable {

    public typealias S = U

    public let mockModel: U

    public init(mockModel: U) {
        self.mockModel = mockModel
    }

    public func serve(order: Order, delivery: (Delivery<S>)->()) {
        delivery(.Success(self.mockModel))
    }

}
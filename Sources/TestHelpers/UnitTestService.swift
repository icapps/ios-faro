
public class UnitTestService <U>: Serveable {

    public typealias T = U

    public init() {

    }

    public func serve<T>(order: Order, delivery: (Delivery<T>)->()) {
        //TODO
    }

}
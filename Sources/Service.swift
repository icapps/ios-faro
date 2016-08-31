
/// Serves your order to a local or a remote bar

public protocol Serveable {

    associatedtype T

    func serve<T>(order: Order, delivery: ()->(Delivery<T>))

}
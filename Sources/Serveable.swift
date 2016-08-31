
/// Serves your order to a local or a remote bar

public protocol Serveable {
    associatedtype S

    func serve(order: Order, delivery: (Delivery<S>)->())
}
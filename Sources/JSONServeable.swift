
/// Serves your order to a local or a remote bar

public protocol JSONServeable {
    
    func serve(order: Order, result: (JSONResult)->())
}
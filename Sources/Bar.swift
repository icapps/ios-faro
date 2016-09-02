
import Foundation

/// Serves anything you order.
/// `Bar` tries to map any JSON to a `Mappable` type.
public class Bar {
    public let configuration : Configuration

    public init (configuration: Configuration) {
        self.configuration = configuration
    }

    /// Receives JSON from the a `Service` and maps this to a `Result` of type `M` that is Mappable.
    /// - parameter order : gives the details to find the entity on the server
    /// - parameter service : default = `JSONService` fires the `Order` to a server
    /// - parameter result : enum containing the requested entity of type `M` on succes or a failure.
    public func serve <M: Mappable> (order : Order, service: Service = JSONService(), result : (Result <M>)->()) {
        service.serve(order) { (jsonResult : Result <M>) in
            switch jsonResult {
            case .JSON(json: let json):
                let model = M(json : json)
                result(.Model(model))
            default:
                print("💣 damn this should not happen")
            }
        }
    }
}
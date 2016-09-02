
import Foundation

/// Serves anything you order.
/// `Bar` tries to map any JSON to a `Mappable` type.
public class Bar {
    public let configuration : Configuration

    public init (configuration: Configuration) {
        self.configuration = configuration
    }

    /// Receives JSON from the service and maps this to a `Result` of type `M` that is Mappable.
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
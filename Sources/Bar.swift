
import Foundation

/// Serves anything you order.
/// `Bar` tries to map any JSON to a `Mappable` type.
public class Bar {
    public let configuration : Configuration
    public let service : JSONServeable

    public init (configuration: Configuration, service: JSONServeable = JSONService()) {
        self.configuration = configuration
        self.service = service
    }

    /// Receives JSON from the service and maps this to a `Result` of type `T` that is Mappable.
    public func serve<T: Mappable>(order : Order, result : (Result<T>)->()) {

        service.serve(order) { (jsonResult) in
            switch jsonResult {
            case .Success(let json):
                let model = T(json : json)
                result(.Success(model))
            default:
                print("💣 damn this should not happen")
            }
        }
    }
}
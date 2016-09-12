
import Foundation

/// Serves anything you order.
/// `Bar` tries to map any JSON to a `Mappable` type.
public class Bar {
    public let service: Service

    public init (service: Service) {
        self.service = service
    }

    /// Receives JSON from the a `Service` and maps this to a `Result` of type `M` that is Mappable.
    /// Typ! You can subclass 'Bar' and add a default service
    /// - parameter order : gives the details to find the entity on the server
    /// - parameter service : default = `JSONService` fires the `Order` to a server
    /// - parameter result : enum containing the requested entity of type `M` on succes or a failure.
    public func perform <M: Mappable> (order: Call, result: (Result <M>) -> ()) {
        service.perform(order) { (jsonResult: Result <M>) in
            switch jsonResult {
            case .JSON(json: let json):
                let model = M(json: json)
                result(.Model(model))
            default:
                result(.Failure(Error.General))
                print("💣 damn this should not happen")
            }
        }
    }
}
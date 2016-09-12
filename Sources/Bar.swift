
import Foundation

/// Serves anything you order.
/// `Bar` tries to map any JSON to a `Mappable` type.
public class Bar {
    public let service: Service

    public init (service: Service) {
        self.service = service
    }

    /// Receives expecte result  as defined by the `adaptor` from the a `Service` and maps this to a `Result` case `case Model(M)`
    /// Default implementation expects `adaptor` to be     case JSON(AnyObject). If this needs to be different you need to override this method.
    /// Typ! You can subclass 'Bar' and add a default service
    /// - parameter call : gives the details to find the entity on the server
    /// - parameter result : `Result<M: Mappable>` closure should be called with `case Model(M)` other cases are a failure.
    public func perform <M: Mappable> (call: Call, toModelResult result: (Result <M>) -> ()) {
        service.perform(call) { (jsonResult: Result <M>) in
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
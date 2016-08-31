
import Foundation

/// Serves anything you order.
public class Bar {
    public let configuration : Configuration
    public let service : JSONServeable

    public init (configuration: Configuration, service: JSONServeable = JSONService()) {
        self.configuration = configuration
        self.service = service
    }

    public func serve<T: Parseable>(order : Order, result : (Result<T>)->()) {

        service.serve(order) { (jsonResult) in
            switch jsonResult {
            case .Success(let json):
                let model = T(json : json)
                result(.Success(model))
            default:
                print("bla")
            }
        }
    }
}
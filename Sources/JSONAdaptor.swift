import Foundation

public class JSONAdaptor: Adaptable {

    public init() {

    }

    public func serialize<M: Mappable>(fromDataResult dataResult: Result<M>, result: (Result <M>) -> ()) {
        switch dataResult {
        case .Data(let data):
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                result(.JSON(json))
            } catch {
                result(.Failure(Error.Error(error)))
            }
        default:
            result(dataResult)
        }
    }

}
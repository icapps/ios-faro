import Foundation

public class JSONAdaptor {

    public init() {

    }

    public func serializeJSONFromDataResult<M: Mappable>(dataResult: Result<M>, jsonResult: (Result <M>) -> ()) {
        switch dataResult {
        case .Data(let data):
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                jsonResult(.JSON(json))
            } catch {
                jsonResult(.Failure(Error.Error(error)))
            }
        default:
            jsonResult(dataResult)
        }
    }

}
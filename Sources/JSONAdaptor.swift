import Foundation

public class JSONAdaptor: Adaptable {

    public init() {

    }

    public func serialize<M: Parseable>(fromDataResult dataResult: Result<M>, result: (Result <M>) -> ()) {
        switch dataResult {
        case .Data(let data):
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                result(.JSON(json))
            } catch {
                guard let faroError = error as? Error else {
                    print("💣 Unknown error \(error)")
                    result(.Failure(Error.General))
                    return
                }

                result(.Failure(faroError))
            }
        default:
            result(dataResult)
        }
    }

}

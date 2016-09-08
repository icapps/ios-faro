public class Service {
    public let configuration: Configuration

    public init(configuration: Configuration) {
        self.configuration = configuration
    }

    /// You should override this. Example use can be found in `JSONService`
    public func serve<M: Mappable>(order: Order, result: (Result <M>) -> ()) {
        result(.Failure(Error.ShouldOverride))
    }

}

public func checkStatusCodeAndData<M: Mappable>(data: NSData?, urlResponse: NSURLResponse?, error: NSError?, result: (Result<M>) -> ()) {
    guard error == nil else {
        let returnError = Error.ErrorNS(error)
        printError(returnError)
        result(.Failure(returnError))
        return
    }

    guard let httpResponse = urlResponse as? NSHTTPURLResponse else {
        let returnError = Error.General
        printError(returnError)
        result(.Failure(returnError))
        return
    }

    let statusCode = httpResponse.statusCode
    guard statusCode != 404 else {
        let returnError = Error.InvalidAuthentication
        printError(returnError)
        result(.Failure(returnError))
        return
    }

    guard 200...201 ~= statusCode else {
        let returnError = Error.General
        printError(returnError)
        result(.Failure(returnError))
        return
    }

    guard let guardedData = data else {
        result(.OK)
        return
    }

    result(.Data(guardedData))

    return
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

/// Catches any throws and switches if to af failure after printing the error.
public func printError(error: Error) {
    switch error {
    case Error.Error(let error):
        print("💣 Error from service: \(error)")
    case Error.ErrorNS(let nserror):
        print("💣 Error from service: \(nserror)")
    case Error.General:
        print("💣 General service error")
    case Error.InvalidResponseData(_):
        print("🤔 Invalid response data")
    case Error.InvalidAuthentication:
        print("💣 Invalid authentication")
    case Error.ShouldOverride:
        print("💣 You should override this method")
    default:
        print("💣 failed with unknown error \(error)")

    }
}
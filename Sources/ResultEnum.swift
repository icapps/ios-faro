/// `Result` is used to deliver results mapped in the `Bar`.
public enum Result<M: Mappable> {
    case Model(M)
    /// The server returned a valid JSON response.
    case JSON(AnyObject)
    case Failure(ErrorType)
}

/// Catches any throws and switches if to af failure after printing the error.
public func convertAllThrowsToResult<M: Mappable>(result: (Result<M>) -> (), thrower: () throws -> ()) {
    do {
        try thrower()
    } catch Error.Error(let nserror) {
        print("💣 Error from service: \(nserror)")
        result(.Failure(Error.Error(nserror)))
    } catch Error.General {
        print("💣 General service error")
        result(.Failure(Error.General))
    } catch Error.InvalidResponseData(let data) {
        print("🤔 Invalid response data")
        result(.Failure(Error.InvalidResponseData(data)))
    } catch Error.InvalidAuthentication {
        print("💣 Invalid authentication")
        result(.Failure(Error.InvalidAuthentication))
    } catch Error.ShouldOverride {
        print("💣 You should override this method")
        result(.Failure(Error.ShouldOverride))
    } catch {
        print("💣 failed with unknown error \(error)")
        result(.Failure(error))
    }
}
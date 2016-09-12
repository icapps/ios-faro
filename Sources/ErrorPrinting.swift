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
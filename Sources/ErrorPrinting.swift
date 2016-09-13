import Stella

/// Catches any throws and switches if to af failure after printing the error.
public func printError(error: Error) {
    switch error {
    case .General:
        printError("General service error")
    case .InvalidUrl(let url):
        printError("invalid url: \(url)")
    case .InvalidResponseData(_):
        printError("Invalid response data")
    case .InvalidAuthentication:
        printError("Invalid authentication")
    case .ShouldOverride:
        printError("You should override this method")
    case .Error(domain: let domain, code: let code, userInfo: let userInfo):
        printError("Error from service: domain: \(domain) code: \(code) userInfo: \(userInfo)")
    }
}
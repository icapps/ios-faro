// TODO: import Stella and use print functions

/// Catches any throws and switches if to af failure after printing the error.
public func printError(error: Error) {
    switch error {
    case .General:
        print("💣 General service error")
    case .InvalidUrl(let url):
        print("💣 invalid url: \(url)")
    case .InvalidResponseData(_):
        print("🤔 Invalid response data")
    case .InvalidAuthentication:
        print("💣 Invalid authentication")
    case .ShouldOverride:
        print("💣 You should override this method")
    case .Error(domain: let domain, code: let code, userInfo: let userInfo):
        print("💣 Error from service: domain: \(domain) code: \(code) userInfo: \(userInfo)")
    }
}
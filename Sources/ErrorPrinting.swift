
/// Catches any throws and switches if to af failure after printing the error.
public func printError(_ error: Error) {
    var faroError = error
    if !(error is FaroError) {
        faroError = FaroError.nonFaroError(error)
    }
    switch faroError as! FaroError {
    case .general:
        print("💣 General service error")
    case .invalidUrl(let url):
        print("💣invalid url: \(url)")
    case .invalidResponseData(_):
        print("💣 Invalid response data")
    case .invalidAuthentication:
        print("💣 Invalid authentication")
    case .shouldOverride:
        print("💣 You should override this method")
    case .nonFaroError(let nonFaroError):
        print("💣 Error from service: \(nonFaroError)")
    case .rootNodeNotFound(json: let json):
        print("💣 Could not find root node in json: \(json)")
    case .networkError(let networkError):
        print("💣 HTTP error: \(networkError)")
    case .emptyCollection:
        print("empty collection")
    case .emptyKey:
        print("missing key")
    case .emptyValue(let key):
        print("no value for key " + key)
    case .malformed(let info):
        print(info)
    }
    
}

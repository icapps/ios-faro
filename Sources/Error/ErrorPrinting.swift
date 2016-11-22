import Foundation

public func printFaroError(_ error: Error) {
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
    case .networkError(let networkError, let data):
        if let data = data {
            //TODO: FARO-29 Print this from the content type returned.
            let string = String(data: data, encoding: .utf8)
            print("💣 HTTP error: \(networkError) message: \(string)")
        } else {
            print("💣 HTTP error: \(networkError)")
        }
    case .emptyCollection:
        print("💣 empty collection")
    case .emptyKey:
        print("💣 missing key")
    case .emptyValue(let key):
        print("❓no value for key " + key)
    case .malformed(let info):
        print("💣 \(info)")
    case .serializationError:
        print("💣serialization error")
    case .updateNotPossible(json: let json, model: let model):
        print("❓ update not possilbe with \(json) on model \(model)")
    }
    
}

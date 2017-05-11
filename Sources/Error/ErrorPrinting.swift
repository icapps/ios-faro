import Foundation

public func printFaroError(_ error: Error) {
    var faroError = error
    if !(error is FaroError) {
        faroError = FaroError.nonFaroError(error)
    }
    switch faroError as! FaroError {
    case .general:
        print("📡🔥 General service error")
    case .invalidUrl(let url):
        print("📡🔥invalid url: \(url)")
    case .invalidResponseData(_):
        print("📡🔥 Invalid response data")
    case .invalidAuthentication:
        print("📡🔥 Invalid authentication")
    case .shouldOverride:
        print("📡🔥 You should override this method")
    case .nonFaroError(let nonFaroError):
        print("📡🔥 Error from service: \(nonFaroError)")
    case .rootNodeNotFound(json: let json):
        print("📡🔥 Could not find root node in json: \(json)")
    case .networkError(let networkError, let data):
        if let data = data {
			guard var string = String(data: data, encoding: .utf8), (string.hasPrefix("{") || string.hasPrefix("[")) else {
				print("📡🔥 HTTP error: \(networkError) no message in utf8 format.")
				return
			}

			do {
				let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
				let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
				string = String(data: prettyPrintedData, encoding: .utf8) ?? "Invalid json"
			} catch {
				// ignore
			}

			print("📡🔥 HTTP error: \(networkError) message: \(string)")
        } else {
            print("📡🔥 HTTP error: \(networkError)")
        }
    case .emptyCollection:
        print("📡🔥 empty collection")
    case .emptyKey:
        print("📡🔥 missing key")
    case .emptyValue(let key):
        print("❓no value for key " + key)
    case .malformed(let info):
        print("📡🔥 \(info)")
    case .serializationError:
        print("📡🔥 serialization error")
    case .updateNotPossible(json: let json, model: let model):
        print("❓ update not possilbe with \(json) on model \(model)")
    case .invalidSession(message: let message):
        print("💀 you tried to perform a request on a session that is invalid")
        print("💀 message: \(message)")
    }
    
}

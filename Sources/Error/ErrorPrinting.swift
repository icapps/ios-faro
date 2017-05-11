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
	case .rootNodeNotFoundIn(json: let json, call: let call):
		print("📡🔥 \(call) no root node in json: \(json) ")
	case .networkError(let networkError, let data, let request):
		if let data = data {
			guard var string = String(data: data, encoding: .utf8), (string.hasPrefix("{") || string.hasPrefix("[")) else {
				print("📡🔥 HTTP error: \(networkError) in \(request) no message in utf8 format.")
				return
			}

			do {
				let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
				let prettyPrintedData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
				string = String(data: prettyPrintedData, encoding: .utf8) ?? "Invalid json"
			} catch {
				// ignore
			}

			print("📡🔥 HTTP error: \(networkError) in \(request) message: \(string)")
		} else {
			print("📡🔥 HTTP error: \(networkError) in \(request)")
		}
	case .malformed(let info):
		print("📡🔥 \(info)")
	case .invalidSession(message: let message, request: let request):
		print("📡🔥 you tried to perform a \(request) on a session that is invalid")
		print("📡🔥 message: \(message)")
	case .couldNotCreateTask:
		print("📡🔥 a valid urlSessionTask could not be created")
	case .noModelOf(type: let type, inJson: let json, call: let call):
		print("📡🔥 \(call) could not instantiate of type \(type) form \(json).")
	case .invalidDeprecatedResult(resultString: let result, call: let call):
		print("📡🔥 \(call) invalid \(result)")
	case .noUpdateModelOf(type: let type, ofJsonNode: let node, call: let call):
		print("📡🔥 \(call) could not update model of type \(type) form json: \(node).")
	case .couldNotCreateInstance(ofType: let type, call: let call, error: let error):
		print("📡🔥 \(call) could not create instance of type \(type) \(error).")
        
    case .parameterNotRecognized(message: let message):
        print("📡🔥 message: \(message)")
	case .jsonAdaptor(error: let error):
		print("📡🔥 \(faroError)")
	}
}

import Foundation

/**
* It is te task of this class to handle the errors related to a response.
*/

public class ResponseController {
	
	public init() {
		
	}
	
	func handleResponse(response:  (data: NSData?, urlResponse: NSURLResponse?, error: NSError?), completion: (response: NSURLResponse)->()) {
		if (response.error == nil) {
			// Success
			let statusCode = (response.urlResponse as! NSHTTPURLResponse).statusCode
			print("--------------URL Session Task Succeeded: HTTP \(statusCode)---------------")
			completion(response: response.urlResponse!)
		}
		else {
			// Failure
			print("URL Session Task Failed: %@", response.error!.localizedDescription);
		}
	}
}

enum UmbrellaErrors: ErrorType {
	case badBody
}
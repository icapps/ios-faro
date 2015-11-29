import Foundation


enum UmbrellaErrors: ErrorType {
	case badBody
}

public class RequestController <BodyType: BaseModel> {
	private let serviceParameters: ServiceParameter
	
	public init(serviceParameters: ServiceParameter) {
		self.serviceParameters = serviceParameters
	}
	
	public func saveBody(body: BodyType){
		
	}
	
	public func sendRequest(completion:(response: NSURLResponse)->()) {
		
		let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		
		let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
		
		let request = serviceParameters.request
		request.HTTPMethod = "POST"
		// JSON Body -> Move to body class
		
		let bodyObject = [
			"score": 1337,
			"cheatMode": false,
			"playerName": "Sean Plott"
		]
	
		request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		
		/* Start a new Task */
		let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
			if (error == nil) {
				// Success
				let statusCode = (response as! NSHTTPURLResponse).statusCode
				print("--------------URL Session Task Succeeded: HTTP \(statusCode)---------------")
				completion(response: response!)
			}
			else {
				// Failure
				print("URL Session Task Failed: %@", error!.localizedDescription);
			}
		}
		
		task.resume()
	}
	
}

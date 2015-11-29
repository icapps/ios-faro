import Foundation


enum UmbrellaErrors: ErrorType {
	case badBody
}

public class RequestController <BodyType: BaseModel> {
	private let serviceParameters: ServiceParameter
	private let sessionConfig: NSURLSessionConfiguration
	private let session: NSURLSession
	
	public init(serviceParameters: ServiceParameter) {
		self.serviceParameters = serviceParameters
		sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	}
	
	public func saveBody(body: BodyType, completion:(response: NSURLResponse)->()){
		let request = serviceParameters.request
		request.HTTPMethod = "POST"
		
		if let bodyObject = body.body() {
			request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		}
		
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

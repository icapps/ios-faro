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
		
		
		let URL = NSURL(string: "\(serviceParameters.serverUrl)GameScore")
		let request = NSMutableURLRequest(URL: URL!)
		request.HTTPMethod = "POST"
		
		// Headers
		
		request.addValue("oze24xbiOCeIdsM11C6MXK2RMLunOmoAWQ5VB6XZ", forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("Bd99hIeNb8sa0ZBIVLYWy9wpCz4Hb5Kvri3NiqBu", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		
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

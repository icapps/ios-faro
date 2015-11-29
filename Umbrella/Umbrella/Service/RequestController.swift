import Foundation


/**
* It is te task of this class to form a request and fire it off.
*/

public class RequestController {
	private let serviceParameters: ServiceParameter
	private let responseController: ResponseController
	private let sessionConfig: NSURLSessionConfiguration
	private let session: NSURLSession
	
	public init(serviceParameters: ServiceParameter, responseController: ResponseController = ResponseController()) {
		self.serviceParameters = serviceParameters
		self.responseController = responseController
		sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	}
	
	public func save<BodyType: BaseModel, ResponseType: BaseModel>(body: BodyType, completion:(response: ResponseType)->()){
		let request = serviceParameters.request
		request.HTTPMethod = "POST"
		
		if let bodyObject = body.body() {
			request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		}
		
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			self.responseController.handleResponse((data: data, urlResponse: response, error: error), completion: completion)
		})
		
		task.resume()

	}
	
	public func retrieve<ResponseType: BaseModel>(completion:(response: [ResponseType])->()){
		let request = serviceParameters.request
		request.HTTPMethod = "GET"
		
		/* Start a new Task */
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			self.responseController.handleResponse((data: data, urlResponse: response, error: error), completion: completion)
		})
		
		task.resume()
		
	}
}

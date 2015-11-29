import Foundation


/**
* It is te task of this class to form a request and fire it off.
*/

public class RequestController {
	private let responseController: ResponseController
	private let sessionConfig: NSURLSessionConfiguration
	private let session: NSURLSession
	
	public init(serviceParameters: ServiceParameter, responseController: ResponseController = ResponseController()) {
		self.responseController = responseController
		sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	}
	
/**
* Save a single item
*/
	public func save<BodyType: BaseModel, ResponseType: BaseModel>(body: BodyType, completion:(response: ResponseType) ->()) throws{
		let request = BodyType.serviceParameters().request
		request.HTTPMethod = "POST"
		
		if let bodyObject = body.body() {
			do {
				request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
			}catch {
				try body.errorController.requestBodyError()
			}
		}else {
			try body.errorController.requestBodyError()
		}
		
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			self.responseController.handleResponse((data: data, urlResponse: response, error: error), completion: completion)
		})
		
		task.resume()

	}
	
/**
* Retrieve a all item fram a concrete class of BaseModel
*/
	public func retrieve<ResponseType: BaseModel>(completion:(response: [ResponseType])->()){
		let request = ResponseType.serviceParameters().request
		request.HTTPMethod = "GET"
		
		/* Start a new Task */
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			self.responseController.handleResponse((data: data, urlResponse: response, error: error), completion: completion)
		})
		
		task.resume()
		
	}
	
	/**
	* Retrieve a single item fram a concrete class of BaseModel
	*/
	public func retrieve<ResponseType: BaseModel>(objectId:String, completion:(response: ResponseType)->()){
		let request = ResponseType.serviceParameters().request
		request.URL = request.URL!.URLByAppendingPathComponent(objectId)
		request.HTTPMethod = "GET"
		
		/* Start a new Task */
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			self.responseController.handleResponse((data: data, urlResponse: response, error: error), completion: completion)
			})
		
		task.resume()
		
	}
}

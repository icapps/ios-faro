import Foundation


// It is te task of this class to fire of a request it gets from the Model Type

//TODO: #6 remove duplication

public class RequestController <Type: BaseModel> {
	private let responseController: ResponseController
	private let sessionConfig: NSURLSessionConfiguration
	private let session: NSURLSession
	
	public init(serviceParameters: ServiceParameters, responseController: ResponseController = ResponseController()) {
		self.responseController = responseController
		sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	}
	
/**
 Save a single item
*/
	public func save(body: Type, completion:(response: Type)->(), failure:((RequestError) ->())? = nil) throws {
		let request = Type.serviceParameters().request
		request.HTTPMethod = "POST"

		guard let bodyObject = body.body() else {
			try body.errorController.requestBodyError()
			return
		}

		do {
			request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		}catch {
			try body.errorController.requestBodyError()
		}

		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			guard error == nil else {
				let taskError = error!
				print("---Error request failed with error: \(taskError)----")
				do {
					try body.errorController.requestResponseError(taskError)
				}catch {
					failure?(RequestError.ResponseError(error: taskError))
				}
				failure?(RequestError.ResponseError(error: taskError))
				return
			}

			do {
				try self.responseController.handleResponse((data: data,urlResponse: response, error: error), body: body, completion: completion)
			}catch RequestError.InvalidAuthentication {
				print("---Error we could not Authenticate----")
				do {
					try body.errorController.requestAuthenticationError()
				}catch {
					failure?(RequestError.InvalidAuthentication)
				}
			}catch {
				print("---Error we could not process the response----")
				do {
					try body.errorController.requestGeneralError()
				}catch {
					failure?(RequestError.General)
				}
			}
		})

		task.resume()
	}
	
/**
* Retrieve a all item fram a concrete class of BaseModel
*/
	public func retrieve(completion:(response: [Type])->(), failure:((RequestError)->())? = nil) throws{
		let request = Type.serviceParameters().request
		request.HTTPMethod = "GET"
		
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			if let error = error {
				print("---Error request failed with error: \(error)----")
				failure?(RequestError.ResponseError(error: error))
			}else {
				do {
					try self.responseController.handleResponse((data: data,urlResponse: response, error: error), completion: completion)
				}catch RequestError.InvalidAuthentication {
					print("---Error we could not Authenticate----")
					failure?(RequestError.InvalidAuthentication)
				}catch {
					print("---Error we could not process the response----")
					failure?(RequestError.General)
				}
			}
		})
		
		task.resume()
		
	}
	
	/**
	* Retrieve a single item from a concrete class of BaseModel
	*/
	public func retrieve(objectId:String, completion:(response: Type)->(),failure:((RequestError)->())? = nil) throws{
		let request = Type.serviceParameters().request
		request.URL = request.URL!.URLByAppendingPathComponent(objectId)
		request.HTTPMethod = "GET"
		
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			if error != nil {
				print("---Error request failed with error: \(error)----")
			}else {
				do {
					try self.responseController.handleResponse((data: data,urlResponse: response, error: error), completion: completion)
					
				}catch RequestError.InvalidAuthentication {
					print("---Error we could not Authenticate----")
					failure?(RequestError.InvalidAuthentication)
				}catch {
					print("---Error we could not process the response----")
					failure?(RequestError.General)
				}
			}
		})
		
		task.resume()
		
	}
}

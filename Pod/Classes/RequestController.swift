import Foundation


public typealias ModelProtocol = protocol<UniqueAble, EnvironmentConfigurable, Parsable, ErrorControlable>

/** 
RequestController to handle interactions with a model of a specific Type.
# Tasks

## Save
`Type` is converted to JSON and send as the body of a request
## Retrieve

You can retreive a single instance or an array of objects

## Handle response via `ResponseController`
The response controllers does the actual parsing. In theory you can parse any kind of reponse, for now we only support JSON.

## Pass errors to the errorController of `Type`
Any type can decide to handle error in a specific way that is suited for that `Type` by conforming to protoco `ErrorControlable`.

# Mocking

You can also mock this class via its Type. Take a look at the `GameScoreTest` in example to know how.

*/
public class RequestController <Type: ModelProtocol> {
	private let responseController: ResponseController
	private let sessionConfig: NSURLSessionConfiguration
	private let session: NSURLSession

	/**
	Initialization
	
	- parameter responseController: a default repsonse controller is provided that can handle JSON responses and normal errors related to that. You can always provide your own for more complex cases.
	- returns: A genericly typed Request controller that can handle task for the `Type` you provide.
	*/
	public init(responseController: ResponseController = ResponseController()) {
		self.responseController = responseController
		sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
		session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
	}

	//MARK: - Save
/**
 Save a single item or `Type`. Completion block return on a background queue!
	
	- parameter body: the Type object is converted to JSON and send to the server.
	- parameter completion: closure is called when service request successfully returns
	- parameter failure: optional parameter that we need to implement because the function `dataTaskWithRequest` on a `WebServiceSession` does not throw.
	- throws : TODO
*/
	public func save(body: Type, completion:(response: Type)->(), failure:((RequestError) ->())? = nil) throws {
		let entity = Type()
		let environment = Type().environment()
		let request = environment.request

		request.HTTPMethod = "POST"

		guard let bodyObject = body.body() else {
			try body.responseErrorController().requestBodyError()
			return
		}

		do {
			request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		}catch {
			try body.responseErrorController().requestBodyError()
		}

		guard !environment.shouldMock() else {
			print("🤔 Mocking (\(Type.self)) is mocking saves")
			completion(response: body)
			return
		}
		
		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in

			let errorController = body.responseErrorController()

			guard error == nil else {
				self.handleTaksError(error!, failure: failure, errorController: errorController)
				return
			}
			self.handleTaksSuccess(environment, errorController: errorController, data: data, response: response, body: body, completion: completion, failure: failure)

		})

		task.resume()
	}


	//MARK: - Retrieve
	/**
 Retreive a all items of `Type`. Completion block return on a background queue!
	
	- parameter response: closure is called when service request successfully returns
	- parameter failure: optional parameter that we need to implement because the function `dataTaskWithRequest` on a `WebServiceSession` does not throw.
	- throws :
	*/
	public func retrieve(completion:(response: [Type])->(), failure:((RequestError)->())? = nil) throws{
		let entity = Type()
		let environment = Type().environment()
		environment.request.HTTPMethod = "GET"

		let errorController = Type.requestErrorController()

		guard !environment.shouldMock() else {
			let url = "\(environment.request.HTTPMethod)_\(entity.contextPath())"
			handleTaksSuccess(environment,
			                  errorController: errorController,
			                  data: try mockDataAtUrl(url, transformController: environment.transformController()),
			                  response: nil,
			                  body: nil,
			                  completion: completion,
			                  failure: failure)

			return
		}

		let task = session.dataTaskWithRequest(environment.request, completionHandler: { [unowned self] (data, response, error) -> Void in
			if let error = error {
				self.handleTaksError(error, failure: failure, errorController: errorController)
			}else {
				self.handleTaksSuccess(environment, errorController: errorController, data: data, response: response, body: nil, completion: completion, failure: failure)
			}
		})
		
		task.resume()
		
	}
	
	/**
 Retreive a single item or `Type`. Completion block return on a background queue!
	
	- parameter objectID: Something that uniquely defines the object you are asking for of `Type`
	- parameter completion: closure is called when service request successfully returns
	- parameter failure: optional parameter that we need to implement because the function `dataTaskWithRequest` on a `WebServiceSession` does not throw.
	- throws : TODO
	*/
	public func retrieve(objectId:String, completion:(response: Type)->(),failure:((RequestError)->())? = nil) throws{
		let entity = Type()
		let environment = Type().environment()
		let request = environment.request
		request.HTTPMethod = "GET"
		let errorController = Type.requestErrorController()


		guard !environment.shouldMock() else {
			let url = "\(environment.request.HTTPMethod)_\(entity.contextPath())_\(objectId)"
			handleTaksSuccess(environment,
			                  errorController: errorController,
			                  data: try mockDataAtUrl(url, transformController: environment.transformController()),
			                  response: nil, body: nil,
			                  completion: completion,
			                  failure: failure)
			
			return
		}
		request.URL = request.URL!.URLByAppendingPathComponent(objectId)

		let task = session.dataTaskWithRequest(request, completionHandler: { [unowned self] (data, response, error) -> Void in
			if let error = error {
				self.handleTaksError(error, failure: failure, errorController: errorController)
			}else {
				self.handleTaksSuccess(environment, errorController: errorController, data: data, response: response, body: nil, completion: completion, failure: failure)
			}
		})
		
		task.resume()
	}

	private func mockDataAtUrl(url: String, transformController: TransformController) throws -> NSData?  {
		print("🤔 Mocking (\(Type.self)) with contextPath: \(Type().contextPath())")
		guard let
			fileURL = NSBundle.mainBundle().URLForResource(url, withExtension: transformController.type().rawValue),
			data = NSData(contentsOfURL: fileURL) else {
				throw RequestError.InvalidUrl
			return nil
		}

		return data
	}

	//MARK: Mocking

	//MARK: Functions to split throws into failure closure
	/**
	We have to do this until apple provides a data task that can handle throws in its closures.
	*/

	private func handleTaksSuccess(environment: Transformable, errorController: ErrorController, data: NSData?, response: NSURLResponse?, body: Type?,  completion:(response: Type)->(), failure:((RequestError) ->())?) {
		do {
			try self.responseController.respond(environment, response:(data: data,urlResponse: response), body: body, completion: completion)
		}catch {
			splitErrorType(error, failure: failure, errorController: errorController)
		}
	}

	private func handleTaksSuccess(environment: Transformable, errorController: ErrorController, data: NSData?, response: NSURLResponse?, body: Type?,  completion:(response: [Type])->(), failure:((RequestError) ->())?) {
		do {
			try self.responseController.respond(environment, response: (data: data, urlResponse: response), completion: completion)
		}catch {
			splitErrorType(error, failure: failure, errorController: errorController)
		}
	}

	private func splitErrorType(error: ErrorType, failure: ((RequestError) ->())?, errorController: ErrorController) {

		switch error {
		case RequestError.InvalidAuthentication:
			print("---Error we could not Authenticate----")
			do {
				try errorController.requestAuthenticationError()
			}catch {
				failure?(RequestError.InvalidAuthentication)
			}
		default:
			print("---Error we could not process the response----")
			do {
				try errorController.requestGeneralError()
			}catch {
				failure?(RequestError.General)
			}
		}
	}
	
	private func handleTaksError(taskError: NSError ,failure:((RequestError) ->())?, errorController: ErrorController) {
		print("---Error request failed with error: \(taskError)----")
		do {
			try errorController.requestResponseError(taskError)
		}catch {
			failure?(RequestError.ResponseError(error: taskError))
		}
		failure?(RequestError.ResponseError(error: taskError))
	}
}

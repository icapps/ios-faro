import Foundation


public typealias ModelProtocol = protocol<UniqueAble, EnvironmentConfigurable, Parsable, Mitigatable>

/** 
RequestController to handle interactions with a model of a specific Type. It is intensionaly stateless.

# Tasks

## Save
`Type` is converted to JSON and send as the body of a request
## Retrieve

You can retreive a single instance or an array of objects

## Handle response via `ResponseController`
The response controllers does the actual parsing. In theory you can parse any kind of reponse, for now we only support JSON.

## Pass errors to the errorController of `Type`
Any type can decide to handle error in a specific way that is suited for that `Type` by conforming to protocol `Mitigatable`.

You can inspect how error handling is expected to behave by looking at `RequestControllerSpec` in the tests of the Example project.

# Mocking

You can also mock this class via its Type. Take a look at the `GameScoreTest` in example to know how.

*/
public class RequestController{

	//MARK: - Save
/**
 Save a single item or `Type`. Completion block return on a background queue!
	
	- parameter body: the Type object is converted to JSON and send to the server.
	- parameter session : default NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration()
	- parameter completion: closure is called when service request successfully returns
	- parameter failure: optional parameter that we need to implement because the function `dataTaskWithRequest` on a `WebServiceSession` does not throw.

	- throws : TODO
*/
	public  class func save <Type: ModelProtocol>  (body: Type, session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: nil),
	                  responseController: ResponseController = ResponseController(),
	                  completion:(response: Type)->(), failure:((ResponseError) ->())? = nil) throws {
		let entity = Type()
		let environment = Type().environment()
		let request = environment.request

		request.HTTPMethod = "POST"

		guard let bodyObject = body.toDictionary() else {
			try Type.requestMitigator().requestBodyError()
			return
		}

		do {
			request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		}catch {
			try Type.requestMitigator().requestBodyError()
		}

		guard !environment.shouldMock() else {
			print("🤔 Mocking (\(Type.self)) is mocking saves")
			completion(response: body)
			return
		}

		let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
			guard error == nil else {
				let mitigator = responseController.mitigator(Type())
				RequestController.fail(error!, failure: failure , mitigator: mitigator)
				return
			}
			RequestController.succeed(data, response: response, body: body, completion: completion, failure: failure)

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
	public class func retrieve<Type: ModelProtocol> (session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: nil),
	                     responseController: ResponseController = ResponseController(),
		completion:(response: [Type])->(), failure:((ResponseError)->())? = nil) throws{
		let entity = Type()
		let environment = Type().environment()
		environment.request.HTTPMethod = "GET"

		let errorController = Type.requestMitigator()

		guard !environment.shouldMock() else {
			let url = "\(environment.request.HTTPMethod)_\(entity.contextPath())"
			RequestController.succeed(try mockDataAtUrl(url, transformController: environment.transformController()),
					completion: completion,
			        failure: failure)

			return
		}

		let task = session.dataTaskWithRequest(environment.request, completionHandler: { (data, response, error) -> Void in
			if let error = error {
				let mitigator = responseController.mitigator(Type())
				RequestController.fail(error, failure: failure, mitigator: mitigator)
			}else {
				RequestController.succeed(data, response: response, completion: completion, failure: failure)
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
	public class func retrieve <Type: ModelProtocol> (objectId:String, session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: nil),
	                      responseController: ResponseController = ResponseController(),
	                      completion:(response: Type)->(),failure:((ResponseError)->())? = nil) throws{
		let entity = Type()
		let environment = Type().environment()
		let request = environment.request
		request.HTTPMethod = "GET"
		let mitigator = Type.requestMitigator()


		guard !environment.shouldMock() else {
			let url = "\(environment.request.HTTPMethod)_\(entity.contextPath())_\(objectId)"
			print("🤔 Mocking (\(Type.self)) with contextPath: \(Type().contextPath())")
			RequestController.succeed(try mockDataAtUrl(url, transformController: environment.transformController()),
			       response: nil, body: nil,
			       completion: completion, failure: failure)
			
			return
		}
		request.URL = request.URL!.URLByAppendingPathComponent(objectId)

		let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
			if let error = error {
				let mitigator = responseController.mitigator(Type())
				RequestController.fail(error, failure: failure, mitigator: mitigator)
			}else {
				RequestController.succeed(data, response: response, completion: completion, failure: failure)
			}
		})
		
		task.resume()
	}

	//MARK: Mocking

	//MARK: Functions to split throws into failure closure
	/**
	We have to do this until apple provides a data task that can handle throws in its closures.
	*/

	class func succeed<Type: ModelProtocol> (data: NSData?, response: NSURLResponse? = nil, body: Type? = nil,
	             responseController: ResponseController = ResponseController(),
	             completion:(response: Type)->(), failure:((ResponseError) ->())?) {
		let entity  = Type()
		let environment = entity.environment()
		let errorController = entity.responseMitigator()

		do {
			try responseController.respond(environment, response:(data: data,urlResponse: response), body: body, completion: completion)
		}catch {
			RequestController.splitErrorType(error, failure: failure, mitigator: errorController)
		}
	}

	class func succeed<Type: ModelProtocol> (data: NSData?, response: NSURLResponse? = nil, body: Type? = nil,  completion:(response: [Type])->(),
	             responseController: ResponseController = ResponseController(),
	             failure:((ResponseError) ->())?) {
		let entity  = Type()
		let environment = entity.environment()
		let errorController = entity.responseMitigator()

		do {
			try responseController.respond(environment, response: (data: data, urlResponse: response), completion: completion)
		}catch {
			RequestController.splitErrorType(error, failure: failure, mitigator: errorController)
		}
	}

	class func fail(taskError: NSError ,failure:((ResponseError) ->())?, mitigator: ResponsMitigatable) {
		print("---Error request failed with error: \(taskError)----")
		do {
			try mitigator.requestResponseError(taskError)
		}catch {
			failure?(ResponseError.ResponseError(error: taskError))
		}
		failure?(ResponseError.ResponseError(error: taskError))
	}

	private class func splitErrorType(error: ErrorType, failure: ((ResponseError) ->())?, mitigator: ResponsMitigatable) {

		switch error {
		case ResponseError.InvalidAuthentication:
			do {
				try mitigator.requestAuthenticationError()
			}catch {
				failure?(ResponseError.InvalidAuthentication)
			}
		case ResponseError.InvalidDictionary(dictionary: let dictionary):
			do {
				try mitigator.responseInvalidDictionary(dictionary)
			}catch {
				let responsError = error as! ResponseError
				failure?(responsError)
			}
		default:
			print("---Error we could not process the response----")
			do {
				try mitigator.requestGeneralError()
			}catch {
				failure?(ResponseError.General)
			}
		}
	}
}

func mockDataAtUrl(url: String, transformController: TransformController) throws -> NSData?  {
	guard let
		fileURL = NSBundle.mainBundle().URLForResource(url, withExtension: transformController.type().rawValue),
		data = NSData(contentsOfURL: fileURL) else {
			throw ResponseError.InvalidResponseData
			return nil
	}

	return data
}
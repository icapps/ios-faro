import Foundation


public typealias ModelProtocol = protocol<UniqueAble, EnvironmentConfigurable, Parsable, Mitigatable>

/** 
`Air` handles interactions with a model of a specific Type called `Rivet`. 

This class is intensionaly stateless.

# Tasks

## Save
`Type` is converted to JSON and send as the body of a request
## Retrieve

You can retreive a single instance or an array of objects

## Handle response via `ResponseController`
The response controllers does the actual parsing. In theory you can parse any kind of reponse, for now we only support JSON.

## Pass errors to the errorController of `Type`
Any type can decide to handle error in a specific way that is suited for that `Type` by conforming to protocol `Mitigatable`.

You can inspect how error handling is expected to behave by looking at `AirSpec` in the tests of the Example project.

# Mocking

You can also mock this class via its Type. Take a look at the `GameScoreTest` in example to know how.

*/
public class Air{

	//MARK: - Save
/**
 Save a single item of Type `Rivet`.  Closures are called on a background queue!
	
	- parameter body: the object of type `Rivet` is converted to JSON and send to the server.
	- parameter session : default NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration()
	- parameter succeed: closure is called when service request successfully returns
	- parameter fail: closure called when something in the response fails.
	- throws : Errors related to the request construction.
*/
	public  class func save <Rivet: ModelProtocol>  (body: Rivet, session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: nil),
	                  responseController: ResponseController = ResponseController(),
	                  succeed:(response: Rivet)->(), fail:((ResponseError) ->())? = nil) throws {
		let entity = Rivet()
		let environment = Rivet().environment()
		let request = environment.request

		request.HTTPMethod = "POST"

		guard let bodyObject = body.toDictionary() else {
			try Rivet.requestMitigator().requestBodyError()
			return
		}

		do {
			request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		}catch {
			try Rivet.requestMitigator().requestBodyError()
		}

		guard !environment.shouldMock() else {
			print("🤔 Mocking (\(Rivet.self)) is mocking saves")
			succeed(response: body)
			return
		}

		let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
			guard error == nil else {
				let mitigator = responseController.mitigator(Rivet())
				Air.fail(error!, fail: fail, mitigator: mitigator)
				return
			}
			Air.succeed(data, response: response, body: body, succeed: succeed, fail: fail)

		})

		task.resume()
	}


	//MARK: - Retrieve
	/**
 Retreive a all items of `Type`. Closures are called on a background queue!
	
	- parameter response: closure is called when service request successfully returns
	- parameter fail: closure called when something in the response fails.
	- throws : Errors related to the request construction.
	*/
	public class func retrieve<Type: ModelProtocol> (session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: nil),
	                     responseController: ResponseController = ResponseController(),
		succeed:(response: [Type])->(), fail:((ResponseError)->())? = nil) throws{
		let entity = Type()
		let environment = Type().environment()
		environment.request.HTTPMethod = "GET"

		let errorController = Type.requestMitigator()

		guard !environment.shouldMock() else {
			let url = "\(environment.request.HTTPMethod)_\(entity.contextPath())"
			Air.succeed(try dataAtUrl(url, transformController: environment.transformController()),
			            succeed: succeed, fail: fail)

			return
		}

		let task = session.dataTaskWithRequest(environment.request, completionHandler: { (data, response, error) -> Void in
			if let error = error {
				let mitigator = responseController.mitigator(Type())
				Air.fail(error, fail: fail, mitigator: mitigator)
			}else {
				Air.succeed(data, response: response, succeed: succeed, fail: fail)
			}
		})
		
		task.resume()
		
	}
	
	/**
 Retreive a single item or `Type`. Closures are called on a background queue!
	
	- parameter objectID: Something that uniquely defines the object you are asking for of `Type`
	- parameter succeed: closure is called when service request successfully returns. !on a background queue
	- parameter fail: closure called when something in the response fails.
	- throws : Errors related to the request construction.
	*/
	public class func retrieve <Type: ModelProtocol> (objectId:String, session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: nil),
	                      responseController: ResponseController = ResponseController(),
	                      succeed:(response: Type)->(),fail:((ResponseError)->())? = nil) throws{
		let entity = Type()
		let environment = Type().environment()
		let request = environment.request
		request.HTTPMethod = "GET"
		let mitigator = Type.requestMitigator()


		guard !environment.shouldMock() else {
			let url = "\(environment.request.HTTPMethod)_\(entity.contextPath())_\(objectId)"
			print("🤔 Mocking (\(Type.self)) with contextPath: \(Type().contextPath())")
			Air.succeed(try dataAtUrl(url, transformController: environment.transformController()),
			       succeed: succeed, fail: fail)
			
			return
		}
		request.URL = request.URL!.URLByAppendingPathComponent(objectId)

		let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
			if let error = error {
				let mitigator = responseController.mitigator(Type())
				Air.fail(error, fail: fail, mitigator: mitigator)
			}else {
				Air.succeed(data, response: response, succeed: succeed, fail: fail)
			}
		})
		
		task.resume()
	}

	//MARK: ResponseHandler
	/**
	We have to do this until apple provides a data task that can handle throws in its closures.
	*/

	class func succeed<Rivet: ModelProtocol> (data: NSData?, response: NSURLResponse? = nil, body: Rivet? = nil,
	             responseController: ResponseController = ResponseController(),
	             succeed:(response: Rivet)->(), fail:((ResponseError) ->())?) {
		let entity  = Rivet()
		let environment = entity.environment()
		let errorController = entity.responseMitigator()

		do {
			try responseController.respond(environment, response:(data: data,urlResponse: response), body: body, completion: succeed)
		}catch {
			Air.splitErrorType(error, fail: fail, mitigator: errorController)
		}
	}

	class func succeed<Rivet: ModelProtocol> (data: NSData?, response: NSURLResponse? = nil, body: Rivet? = nil,
	                    responseController: ResponseController = ResponseController(),
	                   succeed:(response: [Rivet])->(), fail:((ResponseError) ->())?) {
		let entity  = Rivet()
		let environment = entity.environment()
		let errorController = entity.responseMitigator()

		do {
			try responseController.respond(environment, response: (data: data, urlResponse: response), completion: succeed)
		}catch {
			Air.splitErrorType(error, fail: fail, mitigator: errorController)
		}
	}

	class func fail(taskError: NSError ,fail:((ResponseError) ->())?, mitigator: ResponsMitigatable) {
		print("---Error request failed with error: \(taskError)----")
		do {
			try mitigator.requestResponseError(taskError)
		}catch {
			fail?(ResponseError.ResponseError(error: taskError))
		}
		fail?(ResponseError.ResponseError(error: taskError))
	}

	private class func splitErrorType(error: ErrorType, fail: ((ResponseError) ->())?, mitigator: ResponsMitigatable) {

		switch error {
		case ResponseError.InvalidAuthentication:
			do {
				try mitigator.requestAuthenticationError()
			}catch {
				fail?(ResponseError.InvalidAuthentication)
			}
		case ResponseError.InvalidDictionary(dictionary: let dictionary):
			do {
				try mitigator.responseInvalidDictionary(dictionary)
			}catch {
				let responsError = error as! ResponseError
				fail?(responsError)
			}
		default:
			print("---Error we could not process the response----")
			do {
				try mitigator.requestGeneralError()
			}catch {
				fail?(ResponseError.General)
			}
		}
	}
}

func dataAtUrl(url: String, transformController: TransformController) throws -> NSData?  {
	guard let
		fileURL = NSBundle.mainBundle().URLForResource(url, withExtension: transformController.type().rawValue),
		data = NSData(contentsOfURL: fileURL) else {
			throw ResponseError.InvalidResponseData
			return nil
	}

	return data
}
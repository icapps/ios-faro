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
	public  class func save <Rivet: ModelProtocol>  (body: Rivet,
	                         session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration()),
	                         responseController: ResponseController = ResponseController(),
	                         succeed:(response: Rivet)->(), fail:((ResponseError) ->())? = nil) throws {
		let entity = Rivet()
		let environment = Rivet().environment()

		guard !environment.shouldMock() else {
			succeed(response: body)
			return
		}

		guard let bodyObject = body.toDictionary() else {
			try Rivet.requestMitigator().requestBodyError()
			return
		}

		let request = environment.request

		do {
			request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(bodyObject, options: .PrettyPrinted)
		}catch {
			try Rivet.requestMitigator().requestBodyError()
		}

		request.HTTPMethod = "POST"
		performAsychonousRequest(request, session: session, responseController: responseController, succeed: succeed, fail: fail)
	}


	//MARK: - Retrieve
	/**
 Retreive a all items of `Type`. Closures are called on a background queue!
	
	- parameter response: closure is called when service request successfully returns
	- parameter fail: closure called when something in the response fails.
	- throws : Errors related to the request construction.
	*/
	public class func retrieve<Type: ModelProtocol> (session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration()),
	                     responseController: ResponseController = ResponseController(),
	                     succeed:(response: [Type])->(), fail:((ResponseError)->())? = nil) throws{
		let entity = Type()
		let environment = Type().environment()
		let mockUrl = "\(environment.request.HTTPMethod)_\(entity.contextPath())"
		environment.request.HTTPMethod = "GET"

		try mockOrPerform(mockUrl, request: environment.request,
		                  environment: environment, responseController: responseController, session: session,
		                  succeed: succeed, fail: fail)
	}
	
	/**
 Retreive a single item or `Type`. Closures are called on a background queue!
	
	- parameter objectID: Something that uniquely defines the object you are asking for of `Type`
	- parameter succeed: closure is called when service request successfully returns. !on a background queue
	- parameter fail: closure called when something in the response fails.
	- throws : Errors related to the request construction.
	*/
	public class func retrieve <Type: ModelProtocol> (objectId:String, session: NSURLSession = NSURLSession(configuration:NSURLSessionConfiguration.defaultSessionConfiguration()),
	                      responseController: ResponseController = ResponseController(),
	                      succeed:(response: Type)->(), fail:((ResponseError)->())? = nil) throws{
		let entity = Type()
		let environment = Type().environment()
		let request = environment.request
		request.HTTPMethod = "GET"
		if let _ = request.URL {
			request.URL = request.URL!.URLByAppendingPathComponent(objectId)
		}

		let mockUrl = "\(environment.request.HTTPMethod)_\(entity.contextPath())_\(objectId)"
		try mockOrPerform(mockUrl, request: request,
		                  environment: environment, responseController: responseController, session: session,
		                  succeed: succeed, fail: fail)
	}

	private class func mockOrPerform <Type: ModelProtocol> (mockUrl: String, request: NSURLRequest,
	                                  environment: protocol<Environment, Mockable, Transformable>,
	                                  responseController: ResponseController, session: NSURLSession,
	                                  succeed:(response: [Type])->(), fail:((ResponseError)->())? = nil) throws {
		guard !environment.shouldMock() else {
			try mockDataFromUrl(mockUrl, transformController: environment.transformController(), responseController: responseController, succeed: succeed, fail: fail)
			return
		}

		performAsychonousRequest(request, session: session, responseController: responseController, succeed: succeed, fail: fail)
	}

	private class func mockOrPerform <Type: ModelProtocol> (mockUrl: String, request: NSURLRequest,
	                                  environment: protocol<Environment, Mockable, Transformable>,
	                                  responseController: ResponseController, session: NSURLSession,
	                                  succeed:(response: Type)->(), fail:((ResponseError)->())? = nil) throws {
		guard !environment.shouldMock() else {
			try mockDataFromUrl(mockUrl, transformController: environment.transformController(), responseController: responseController, succeed: succeed, fail: fail)
			return
		}

		performAsychonousRequest(request, session: session, responseController: responseController, succeed: succeed, fail: fail)
	}

	private class func mockDataFromUrl <Type: ModelProtocol> (url: String, transformController: TransformController, responseController: ResponseController,
	                                    succeed:(response: [Type])->(), fail:((ResponseError)->())? = nil ) throws {
		let data = try dataAtUrl(url, transformController: transformController)
		responseController.respond(data, succeed: succeed, fail: fail)
	}

	private class func mockDataFromUrl <Type: ModelProtocol> (url: String, transformController: TransformController, responseController: ResponseController,
	                                    succeed:(response: Type)->(), fail:((ResponseError)->())? = nil ) throws {
		let data = try dataAtUrl(url, transformController: transformController)
		responseController.respond(data, succeed: succeed, fail: fail)
	}
	
	private class func performAsychonousRequest<Type: ModelProtocol> (request: NSURLRequest,
	                                            session: NSURLSession, responseController: ResponseController,
	                                            succeed:(response: Type)->(), fail:((ResponseError)->())? = nil ) {
		let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
			responseController.respond(data, urlResponse: response, error: error, succeed: succeed, fail: fail)
		})

		task.resume()
	}

	private class func performAsychonousRequest<Type: ModelProtocol> (request: NSURLRequest,
	                                            session: NSURLSession, responseController: ResponseController,
	                                            succeed:(response: [Type])->(), fail:((ResponseError)->())? = nil ) {
		let task = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
			responseController.respond(data, urlResponse: response, error: error, succeed: succeed, fail: fail)
		})

		task.resume()
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
import Foundation

/**
A mitigator tries to make a problem less servere. This is a default implementation that implements all the required protocols:

- `Mitigator` -> capture any thrown errors and rethrow them if needed.
- `ResponseMitigatable` -> Try to handle response errors. By default errors are printed and rethrown.
- `RequestMitigatable` -> Try to handle request errors.  By default errors are printed and rethrown.
*/
@available(*, deprecated=1.0.0, message="use Faro.")

public class MitigatorDefault: Mitigator, ResponseMitigatable, RequestMitigatable {

	public init () {
		
	}

	// MARK: Mitigator
    
	public func mitigate(thrower: ()throws -> ()) throws  {
		do {
			try thrower()
		}catch RequestError.InvalidBody{
			try invalidBodyError()
		}catch RequestError.General{
			try generalError()
		}catch ResponseError.InvalidResponseData(let data){
			try invalidResponseData(data)
		}catch ResponseError.InvalidDictionary(dictionary: let dict) {
			try invalidDictionary(dict)
		} catch ResponseError.ResponseError(error: let error) {
			try responseError(error)
		}catch ResponseError.General(statuscode: let code) {
			try generalError(code)
		}catch ResponseError.GeneralWithResponseJSON(statuscode: let code, responseJSON: let json) {
			try generalError(code, responseJSON: json)
		}catch MapError.EnityShouldBeUniqueForJSON(json: let json, typeName: let typeName) {
			try enityShouldBeUniqueForJSON(json, typeName: typeName)
		}catch MapError.JSONHasNoUniqueValue(json: let json) {
			try jsonHasNoUniqueValue(json)
		}catch {
			throw error
		}
	}

    // MARK: RequestMitigatable
    
	public func invalidBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}

	public func generalError() throws {
		print("💣 General request error")
		throw RequestError.General
	}

    
    // MARK: ResponseMitigatable
    
	public func invalidAuthenticationError() throws {
		print("🙃 Authentication error")
		throw ResponseError.InvalidAuthentication
	}

	public func invalidResponseData(data: NSData?) throws {
        print("🤔 Invalid response data")
        throw ResponseError.InvalidResponseData(data: data)
    }
    

	public func invalidDictionary(dictionary: AnyObject) throws -> AnyObject? {
		print("🤔 Received invalid dictionary \(dictionary)")
		throw ResponseError.InvalidDictionary(dictionary: dictionary)
	}

	public func responseError(error: NSError?) throws {
		print("💣 Request failed with error \(error)")
		throw ResponseError.ResponseError(error: error)
	}


	public func generalError(statusCode: Int) throws -> (){
		print("💣 General response error with statusCode: \(statusCode)")
		throw ResponseError.General(statuscode: statusCode)
	}


	public func generalError(statusCode: Int , responseJSON: AnyObject) throws -> () {
		print("💣 General response error with statusCode: \(statusCode) and responseJSON: \(responseJSON)")
		throw ResponseError.GeneralWithResponseJSON(statuscode: statusCode, responseJSON: responseJSON)
	}

	public func enityShouldBeUniqueForJSON(json: AnyObject, typeName: String) throws {
		print("🤔 We should have a unique entity in database for type: \(typeName) and responseJSON: \(json)")
		throw MapError.EnityShouldBeUniqueForJSON(json: json, typeName: typeName)
	}

	public func jsonHasNoUniqueValue(json: AnyObject) throws {
		print("🤔 json should contain a unique value. Received json: \(json)")
		throw MapError.JSONHasNoUniqueValue(json: json)
	}
}
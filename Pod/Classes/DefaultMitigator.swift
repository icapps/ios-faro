import Foundation

/**
A mitigator tries to make a problem less servere. This is a default implementation that implements all the required protocols:

- `Mitigator` -> capture any thrown errors and rethrow them if needed.
- `ResponseMitigatable` -> Try to handle response errors. By default errors are printed and rethrown.
- `RequestMitigatable` -> Try to handle request errors.  By default errors are printed and rethrown.
*/
public class DefaultMitigator: Mitigator, ResponseMitigatable, RequestMitigatable {

	public init () {
		
	}

	//MARK: Mitigator
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
		}catch {
			throw error
		}
	}

    //MARK: RequestMitigatable
	public func invalidBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}
	
	public func generalError() throws {
		print("-----------General error-----")
		throw RequestError.General
	}

    
    //MARK: ResponseMitigatable
	public func invalidAuthenticationError() throws {
		print("-----------Authentication error-----")
		throw ResponseError.InvalidAuthentication
	}

	public func invalidResponseData(data: NSData?) throws {
        print("💣Invalid response data 💣")
        throw ResponseError.InvalidResponseData(data: data)
    }
    

	public func invalidDictionary(dictionary: AnyObject) throws -> AnyObject? {
		print("-------- Received invalid dictionary \(dictionary)-------")
		throw ResponseError.InvalidDictionary(dictionary: dictionary)
		return nil
	}

	public func responseError(error: NSError?) throws {
		print("-----------Request failed with error-----")
		throw ResponseError.ResponseError(error: error)
	}
}
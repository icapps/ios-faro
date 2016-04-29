import Foundation

public class DefaultMitigator: Mitigator {

	public init () {
		
	}

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

    //MARK: Request
    
	public func invalidBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}
	
	public func generalError() throws {
		print("-----------General error-----")
		throw RequestError.General
	}

    
    //MARK: Response

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
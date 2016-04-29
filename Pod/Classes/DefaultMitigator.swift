import Foundation

public class DefaultMitigator: Mitigator {

	public init () {
		
	}
    //MARK: RequestErrorController
    
	public func requestBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}
	
	public func requestAuthenticationError() throws {
		print("-----------Authentication error-----")
		throw ResponseError.InvalidAuthentication
	}
	
	public func requestGeneralError() throws {
		print("-----------General error-----")
		throw RequestError.General
	}
	
	public func requestResponseError(error: NSError?) throws {
		print("-----------Request failed with error-----")
        if let error = error {
            throw ResponseError.ResponseError(error: error)
        }
	}
    
    //MARK: ResponseErrorController
    
    public func responseDataEmptyError() throws {
        print("-----------Invalid response data-----")
        throw ResponseError.InvalidResponseData
    }
    
    public func responseInvalidError() throws {
        print("-----------Invalid response type-----")
        throw ResponseError.InvalidResponse
	}
	public func responseInvalidDictionary(dictionary: AnyObject) throws -> AnyObject? {
		print("-------- Received invalid dictionary \(dictionary)-------")
		throw ResponseError.InvalidDictionary(dictionary: dictionary)
		return nil
	}

    //MARK: TransformErrorController

//    public func transformJSONError() throws {
//        //
//    }
//    
//    public func transformInvalidObjectERror() throws {
//        //
//    }
}
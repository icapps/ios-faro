import Foundation

public class DefaultMitigator: Mitigator {

	public init () {
		
	}
    //MARK: RequestErrorController
    
	public func invalidBodyError() throws -> () {
		print("-----------Error building up body-----")
		throw RequestError.InvalidBody
	}
	
	public func invalidAuthenticationError() throws {
		print("-----------Authentication error-----")
		throw ResponseError.InvalidAuthentication
	}
	
	public func generalError() throws {
		print("-----------General error-----")
		throw RequestError.General
	}
	
	public func responseError(error: NSError?) throws {
		print("-----------Request failed with error-----")
        if let error = error {
            throw ResponseError.ResponseError(error: error)
        }
	}
    
    //MARK: ResponseErrorController
    
    public func invalidResponseEmptyDataError() throws {
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
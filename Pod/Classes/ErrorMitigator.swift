import Foundation


/**
An `ErrorMitigator` recieves errors that happen. Mitigate means ‘make (something bad) less severe'. 

So do that or rethrow what you cannot handle.
*/
public protocol ErrorMitigator: RequestErrorController, ResponseErrorController, TransformErrorController
{

}

/**
 * This class is responsible to handle errors in general and in a type specific way.
 */

public protocol RequestErrorController {
    func requestBodyError() throws -> ()
    func requestAuthenticationError() throws -> ()
    func requestGeneralError() throws -> ()
    func requestResponseError(error: NSError?) throws -> ()
}

public protocol ResponseErrorController {
    func responseDataEmptyError() throws -> ()
    func responseInvalidError() throws -> ()
	/**
	Your chance to intercept dictionary data that cannot is irregular. You can fix it and don't trow.
	*/
	func responseInvalidDictionary(dictionary: AnyObject) throws -> ()
}

public protocol TransformErrorController {
//    func transformInvalidObjectERror() throws -> ()
//    func transformDictionayError(diction) throws -> ()
}



public enum RequestError: ErrorType {
	case InvalidBody
	case InvalidUrl
	case General
}

public enum ResponseError:ErrorType {
    case InvalidResponse
	case InvalidResponseData
	case InvalidDictionary(dictionary: AnyObject)
	case ResponseError(error: NSError?)
	case InvalidAuthentication
	case General
}
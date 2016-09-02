
public enum Error: ErrorType {
    case General
    case InvalidUrl(String)
    case InvalidResponseData(data: NSData?)
    case ResponseError(error: NSError?)
    case InvalidAuthentication
}
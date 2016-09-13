public enum Error: ErrorType, Equatable {
    case General
    case InvalidUrl(String)
    case InvalidResponseData(NSData?)
    case InvalidAuthentication
    case ShouldOverride
    case Error(domain: String, code: Int, userInfo: [NSObject: AnyObject])
}

public func errorFromNSError(nsError: NSError) -> Error {
    return Error.Error(domain: nsError.domain, code: nsError.code, userInfo: nsError.userInfo)
}

public func == (lhs: Error, rhs: Error) -> Bool {
    switch (lhs, rhs) {
    case (.General, .General):
        return true
    case (.InvalidAuthentication, .InvalidAuthentication):
        return true
    case (.InvalidUrl(let url_lhs), .InvalidUrl(let url_rhs)): // tailor:disable
        return url_lhs == url_rhs
    case (.Error(_), .Error(_)):
        return true
    case (.InvalidResponseData (_), .InvalidResponseData (_)):
        return true
    default:
        return false
    }
}
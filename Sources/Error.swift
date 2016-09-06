public enum Error: ErrorType, Equatable {
    case General
    case InvalidUrl(String)
    case InvalidResponseData(NSData?)
    case Error(NSError?)
    case InvalidAuthentication
    case ShouldOverride
}

public func == (lhs: Error, rhs: Error) -> Bool {
    switch (lhs, rhs) {
    case (.General, .General):
        return true
    case (.InvalidAuthentication, .InvalidAuthentication ):
        return true
    case (.InvalidUrl(let url_lhs), .InvalidUrl(let url_rhs)): // tailor:disable
        return url_lhs == url_rhs
    case (.Error(let error_lhs), .Error(let error_rhs)): // tailor:disable
        return error_lhs?.code == error_rhs?.code
    case (.InvalidResponseData (let _), .InvalidResponseData (let _)):
        return true
    default:
        return false
    }
}
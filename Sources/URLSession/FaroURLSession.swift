import Foundation

open class FaroURLSession {
    public let backendConfiguration: BackendConfiguration
    public let session: URLSession

    public init(backendConfiguration: BackendConfiguration, session: URLSession = URLSession.shared) {
        self.backendConfiguration = backendConfiguration
        self.session = session
    }

}

//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous)
import Faro
//: # Security
/*:
Security is handeled by a FaroSecureURLSession. Every `DeprecatedService` has a session that is by default `FaroURLSession`.

If you want more security options you can Provide a Sublass of `FaroSecureURLSession` or alternativaly implement the `FaroSessionable`. To let Faro know about your session you need to provide it via the `FaroSingleton` or for every instance of `DeprecatedService` you made.

But first implement `FaroSecureURLSession`.

Then add it to Faro
*/
//: ### Via the singleton
func setupFaroWithSecurity() {
    let baseURL = "http://jsonplaceholder.typicode.com"

    let sessionSessionDelegate = FaroURLSessionDelegate(allowUntrustedCertificates: false)
    let secureSession = FaroSecureURLSession(urlSessionDelegate: sessionSessionDelegate)
//   Provide your own singleton to use whenever you need the `secureSession`
}
//: > You have to provide a singleton for a session. use it whereever you instantiate a service.
//: As an example a service that we could have used in this playground!

class FaroPlayGroundService: Service {

    /// Initializes to respond with fake data.
    public init(call: Call, data: Data? = nil, statusCode: Int = 200) {
        let configuration = Configuration(baseURL: "http://www.yourServer.com")
        let response = HTTPURLResponse(url: configuration.baseURL!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let session = MockSession(data: data, urlResponse: response, error: nil)

        super.init(call: call, autoStart: true, configuration: configuration, faroSession: session)
    }
}

//: > You can try to make a service on your own that  always uses a secure session like in setupFaroWithSecurity. You can do this with a singleton or without.

//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous)

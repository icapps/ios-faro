import Faro

//: A service that will fetch product data needs a BackendConfiguration to know the baseURL and a Session to be able to perform network requests.
//: * Configuration is a simple object with some customizable baseURL's. You use it to switch between production or development service.
//: **Side note** we do not really do the a network request. We fetch the json from above. This can be done by using a `MockedSession`.
//: * *Data*: that is normaly returned from the service. Just change `MockedSession` -> `FaroSession` and this will work from any server.
//: Create a session with a response OK (= 200) that returns the data of `jsonArray` above.
public class StubbedFaroURLSession: FaroURLSession {

    public static func setup() {
        let backendConfiguration = BackendConfiguration(baseURL: "http://www.stub.com")
        let urlConfiguration = URLSessionConfiguration.default
        //: Because of the following line the URLSession will behave stubbed for paths that we stub. More below
        urlConfiguration.protocolClasses = [StubbedURLProtocol.self]

        FaroURLSession.setup(backendConfiguration: backendConfiguration, urlSessionConfiguration: urlConfiguration)
    }
}

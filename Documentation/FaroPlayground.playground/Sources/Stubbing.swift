import Faro

//: A service that will fetch product data needs a BackendConfiguration to know the baseURL and a Session to be able to perform network requests.
//: * Configuration is a simple object with some customizable baseURL's. You use it to switch between production or development service.
//: **Side note** we do not really do the a network request. We fetch the json from above. This can be done by using a `MockedSession`.
//: * *Data*: that is normaly returned from the service. Just change `MockedSession` -> `FaroSession` and this will work from any server.
//: Create a session with a response OK (= 200) that returns the data of `jsonArray` above.
public class StubbedFaroURLSession: FaroURLSession {

    public init() {
        let config = URLSessionConfiguration.default
        //: Because of the following line the URLSession will behave stubbed for paths that we stub. More below
        config.protocolClasses = [StubbedURLProtocol.self]

        let stubbedSession = URLSession(configuration: config)

        super.init(backendConfiguration:BackendConfiguration(baseURL: "http://www.google.com"), session: stubbedSession)
    }
}

public class StubService: Service {

    //: Convienience init that stubs the service for a specific call.
    public init(call: Call) {
        //: **AutoStart??** meand that whenever you use the function `perform` the request is immediately fired. If you want to create multiple service instances and fire the request later put **autoStart** to false.
        super.init(call: call, autoStart: true, session: StubbedFaroURLSession())
    }
}

public class StubServiceHandler<M: Decodable>: ServiceHandler<M> {

    public init(call: Call,
                complete: @escaping (() throws -> (M)) -> Void,
                completeArray: @escaping (() throws -> ([M])) -> Void) {

        super.init(call: call, autoStart: true,session: StubbedFaroURLSession(), complete: complete, completeArray: completeArray)
    }
}

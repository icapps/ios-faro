import Faro

class ExampleService: Service {

    init() {
        super.init(configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com"))
    }

    override func perform<M: Mappable>(call: Call, result: (Result<M>) -> ()) {
        super.perform(call, result: result)
    }

}
 import Faro

class ExampleService: Service {

    init() {
        super.init(configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com"))
    }

}

class ExampleServiceQueue: ServiceQueue {

    init(final: @escaping () -> ()) {
        super.init(configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com"), final: final)
    }
    
}

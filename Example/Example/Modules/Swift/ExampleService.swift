import Faro
import Foundation

class ExampleService: Service {

    init() {
        super.init(configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com"))
    }

}

class ExampleServiceQueue: ServiceQueue {

    init(final: @escaping (_ failedTasks: Set<URLSessionTask>?) -> ()) {
        super.init(configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com"), final: final)
    }

}

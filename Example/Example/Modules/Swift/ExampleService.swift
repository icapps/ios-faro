import Faro
import Foundation

class ExampleDeprecatedServiceQueue: DeprecatedServiceQueue {

    init(final: @escaping (_ failedTasks: Set<URLSessionTask>?) -> ()) {
        super.init(configuration: Configuration(baseURL: "http://jsonplaceholder.typicode.com"), final: final)
    }

}

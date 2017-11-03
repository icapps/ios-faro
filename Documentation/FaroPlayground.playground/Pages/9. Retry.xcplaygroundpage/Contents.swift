//: [Previous](@previous)
//: # Retry
import Faro
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//:  *Real response:*
//: TODO: This is not finished yet. Just a starting point for the future.

let configuration = BackendConfiguration(baseURL: "http://jsonplaceholder.typicode.com")
let response = HTTPURLResponse(url: configuration.baseURL!, statusCode: 200, httpVersion: nil, headerFields: nil)
let session = FaroURLSession(backendConfiguration: configuration)
let call = Call(path: "posts")

class Post: Decodable {
    let uuid: Int
    var title: String?

    private enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case title
    }
}

//: Session with multiple tasks not autostarted

//: TODO: Make it possible to perform multiple calls

let service = ServiceHandler<Post>(call: call, autoStart: true, session: session,
    complete: {
    do {
        let result = try $0()
        print("\(result)")
    } catch {
        // ignore
    }
}, completeArray: {
    do {
        let result = try $0()
        print("\(result.count)")
    } catch {
        // ignore
    }
})

let task1 = service.performArray()
let task2 = service.performArray()
let task3 = service.performArray()
let task4 = service.performArray()


//session.invalidateAndCancel()

task1?.resume()

session.session.getAllTasks {
    print($0.count)
}


//: [Next](@next)

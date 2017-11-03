//: [Previous](@previous)
//: # Retry
import Faro

//:  *Real response:*


let configuration = Configuration(baseURL: "http://jsonplaceholder.typicode.com")
let response = HTTPURLResponse(url: configuration.baseURL!, statusCode: 200, httpVersion: nil, headerFields: nil)
let session = FaroSession()
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

let service = ServiceHandler<Post>(call: call, autoStart: true, configuration: configuration, faroSession: session,
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
        print("\(result)")
    } catch {
        // ignore
    }
})

let task1 = service.performArray()
let task2 = service.performArray()
let task3 = service.performArray()
let task4 = service.performArray()


//session.invalidateAndCancel()

session.resume(task1!)

session.getAll Tasks {
    print($0)
}


//: [Next](@next)

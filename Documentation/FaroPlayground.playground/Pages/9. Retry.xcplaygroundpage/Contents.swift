//: [Previous](@previous)
//: # Retry
import Faro
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: # Retry

StubbedFaroURLSession.setup()

let call = Call(path: "posts")

let post_1 = """
[
  {
    "id": 1,
    "title": "Post 1"
  },
  {
    "id": 2,
    "title": "Post 2"
  },
  {
    "id": 3,
    "title": "Post 3"
  }
]
""".data(using: .utf8)!

let post_2 = """
[
  {
    "id": 10,
    "title": "Post 10"
  }
]
""".data(using: .utf8)!

let errorData = """
[
  {
    "message": "Token invalid"
  }
]
""".data(using: .utf8)!

//: The stubbing we use allows you to write multiple repsonses for every time a request is performed.

call.stub(statusCode: 401, data: errorData)
call.stub(statusCode: 200, data:post_1)
call.stub(statusCode: 200, data: post_2)

class Post: Decodable {
    let uuid: Int
    var title: String?

    private enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case title
    }
}

//: Session with multiple tasks not autostarted
//: If you put autoStart to false the task that is returned after a perform is not started. This is what we want in this case where we start multiple requests with different repsonses.
let service = StubServiceHandler<Post>(call: call, autoStart: false) {
    let posts = try? $0()
}

service.session.enableRetry { (data, response, error) -> Bool in
    guard let response = response as? HTTPURLResponse, response.statusCode == 401 else {
        return false
    }

    return true
}

let task1 = service.performArray()
let authenticationFailedTask = service.performArray()
let task2 = service.performArray()

authenticationFailedTask?.resume()
DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
    task1?.resume()
    task2?.resume()
}


/*:
 1. Suspend all tasks when you get a 401
 2. Make it possible to define any failure based on the reponse
 3. Start a refresh request token request
 4. Make every task valid again
 5. Resume all suspended and fixed tasks
*/


//: [Next](@next)

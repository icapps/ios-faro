//: [Previous](@previous)

//: ## 3. Single Complete Handler or multiple Closure Parameters
//: setup instances
import Faro

let jsonSingle = """
{
  "name": "Melon",
  "points": 100,
  "description": "Very orange and fruity!"
}
""".data(using: .utf8)!

//: Again provide a fake response:
let configuration = Configuration(baseURL: "http://www.yourServer.com")
let response = HTTPURLResponse(url: configuration.baseURL!, statusCode: 200, httpVersion: nil, headerFields: nil)
let session = MockSession(data: jsonSingle, urlResponse: response, error: nil)
//: *`/products` -> `/<name>`
let call = Call(path: "product")


struct Product: Decodable {
    let name: String
    let points: Int
    let description: String?
}

/*:
 As you can see in the previous example pages data is returned to the service in an asynchronous way. This is done because the time before the service responds can be long. During this time you do not want the UI to be unresponsive. Thats why a background process waits for the response. When it arrives the background process needs a way to reach the UI. In Faro you have 2 options:

 1. A closure parameter. Every `perform` request has its own *block* of code that can be executed when the server responds.
 2. Service can hava handlers. These are stored blocks of code that will be triggered every time the server responds.

 In previous examples we have not yet discussed option 2. Lets dive in now!
*/
//: ### Service handlers

let service = ServiceHandler<Product>(call: call, autoStart: true, configuration: configuration, faroSession: session) { (resultFunction) in
    do {
        let result = try resultFunction()
        print(result)
    } catch {
        let result = error
        // We can ignore the error as we are only printing it.
    }
}

//: From anywhere in your code and as many times as you want you can now ask the service to perform the request. The same completion handler will always be called.

service.perform()

//: [Next](@next)

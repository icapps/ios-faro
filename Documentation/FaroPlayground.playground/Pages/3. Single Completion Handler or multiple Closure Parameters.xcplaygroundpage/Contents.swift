import Faro
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
//: # 3. Single Complete Handler or multiple Closure Parameters
StubbedFaroURLSession.setup()
let jsonSingle = """
{
  "name": "Melon",
  "points": 100,
  "description": "Very orange and fruity!"
}
""".data(using: .utf8)!

let call = Call(path: "product")

call.stub(statusCode: 200, data: jsonSingle)
/*:
 As you can see in the previous example pages data is returned to the service in an asynchronous way. This is done because the time before the service responds can be long. During this time you do not want the UI to be unresponsive. Thats why a background process waits for the response. When it arrives the background process needs a way to reach the UI. In Faro you have 2 options:

 1. A closure parameter. Every `perform` request has its own *block* of code that can be executed when the server responds.
 2. Service can have handlers. These are stored blocks of code that will be triggered every time the server responds.

 In previous examples we have not yet discussed option 2. Lets dive in now!
*/
//: ### Service handlers
let service = ServiceHandler<Product>(call: call, complete: { (done) in
        print((try? done()) ?? "No result")
    })
//: From anywhere in your code and as many times as you want you can now ask the service to perform the request. The same completion handler will always be called.
service.perform()
/*:
 ---
 [Previous](@previous) / [Next](@next)
 */

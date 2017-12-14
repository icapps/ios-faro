import UIKit
import Faro
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
/*:
# 1. Data received as an array
Faro has switched to use the native `Decoder` and `Encoder` in Swift 4. We use the playground Apple provide in [WWDC2017 session: Whats new in Foundation](https://developer.apple.com/videos/play/wwdc2017/212/)

## Grocery store example
In a grocery store there are products. They have a name and an optional description.
To fetch them from de service and have a `GroceryProduct` array do:
1. Create `Decodable` model

 > *More info in folder /Documentation/Using-JSON-with-Custom-Types.playground provided by Apple.*
2. Create a `Service` object and use the perform function
3. Handle the result
*/
//: First make sure we run stubbed network requests
StubbedFaroURLSession.setup()
//: Create stubbed data that can be returned by the service.
let jsonArray = """
[
    {
        "name": "Banana",
        "points": 200,
        "description": "A banana grown in Ecuador."
    },
    {
        "name": "Orange",
        "points": 100
    }
]
""".data(using: .utf8)!
/*: > For more information about how we stub the session to return the data from 'jsonArray' you should take a look at Stubbing.swift file in sources folder.

 Every service object is also linked to a specific *endpoint* example: `<baseURL>/products`. To define an endpoint we use an object called `Call`.
 */
let call = Call(path: "products")
//: A call can be handled by a service object. In your code you are encouraged to created subclasses per call.
let service = Service(call: call)
//: Now we will stub the call with the data from above. We will call 4 times wo me need to stub 3 times.
call. (statusCode: 200, data: jsonArray)
call.stub(statusCode: 200, data: jsonArray)
call.stub(statusCode: 200, data: jsonArray)
call.stub(statusCode: 200, data: jsonArray)
/*:
 The function `perform` can decode any type of model that implements `Decodable`. Luckaly in most cases to implement decodable you do **nothing**!
The first parameter is the type. In Swift of any type you can pass the type itself as a parameter by using *Type.self*.
 */
 service.perform([Product].self) { (done) in
        // see explanation below on how to get the product array
 }
/*:
 ## Getting the result via a throwing function
This might seam wierd at first but actually allows you to write condense and descriptive code. In Swift funtions are like variables. You can use them in the same way as you would use an `Int` variable. To get my head around this 2 things helped:

> 1. The syntax is wierd but condense. `var function: () -> Void` means that the type of the variable function is a function 🙃. You can assign any function that takes no arguments `()` and returns nothing `Void`
> 2. Before any function returns a value something can go wrong. To report back to the caller of the function that something went wrong you have 2 options: `return nil` or `throw error`

 ### `Return` to end execution version `throw`
Both return and throw end the execution of the program at a specific line.

 1. code
 2. code
 3. `return`
 4. code // will not be executed

 Same goes for throw
 1. code
 2. code
 3. `throw error`
 4. code // will not be executed

  The main difference is that at line 3 we want to tell the caller of the function what went wrong. This difficult with return nil. The error thrown is more descriptive.
*/
service.perform([Product].self) { (done) in
    do {
        let products = try done()
        products.forEach { print("🚀 We have \($0)")}

    }
        //: Generic way to catch the error and inspect what is going wrong
    catch let error as ServiceError where error.decodingErrorMissingKey != nil {
        print("Error with missing key \\\(error.decodingErrorMissingKey!)")
    } catch {
        // ignore error
    }
}
/*:
> !Try to remove the name or points form `jsonArray` an see the error described.
> !! Faro also prints the errors so you should not do this in code !!!

 So you can write the above more condense
 */

service.perform([Product].self) { (done) in
        (try? done())?.forEach { print("🚀🚀 We have \($0)")}
}
//: Because of swift implicit arguments in closures we can replace `done` with `$0`
service.perform([Product].self) { (try? $0())?.forEach { print("🚀🚀🚀 We have \($0)")} }
/*: In the 2 last result we do not use the error. This is because Faro prints any error. So if you do not show the error to the user you can ignore it by writing `try?` which makes `nil` from the thrown `error`.
---
 [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
 */

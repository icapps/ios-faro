//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
import UIKit
import Faro
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: # Fetch Data from Array
//:
//: Faro has switched to use the native `Decoder` and `Encoder` in Swift 4. We use the playground Apple provide in [WWDC2017 session: Whats new in Foundation](https://developer.apple.com/videos/play/wwdc2017/212/)
//:
//: ## Grocery store example
//:
//: In a grocery store there are products. They have a name and an optional description.
//: To fetch them from de service and have a `GroceryProduct` array do:
//:
//: 1. Create 'Decodable model (More info in folder /Documentation/Using-JSON-with-Custom-Types.playground provided by Apple.)
//: 2. Create a `Service` object and use the perform function
//: 3. Handle the result

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
//: > For more information about how we stub the session to return the data from 'jsonArray' you should take a look at Stubbing.swift file in sources folder.
//: * Every service object is also linked to a specific *endpoint* example: `<baseURL>/products`. To define an endpoint we use an object called `Call`.
let call = Call(path: "products")
//: StubService is a subclass of Service created for this playground. In your own code you can create one to to subclass all services from to do some general setup. Take a look at file Stubbing.swift.
let service = StubService(call: call)

//: Now we will stub the call with the data from above
call.stub(statusCode: 200, body: jsonArray)

//*: The function `perform` can decode any type of model that implements `Decodable`. Luckaly in most cases to implement decodable you do **noting**!
//: The first parameter is the type. In Swift of any type you can pass the type itself as a parameter by using *Type.self*.
//: ## Getting the result via a throwing function
//: This might seam wierd at first but actually allows you to write condense and descriptive code. In Swift funtions are like variables. You can use them in the same way as you would use an `Int` variable. To get my head around this 2 things helped:
//: > 1. The syntax is wierd but condense. `var function: () -> Void` means that the type of the variable function is a function 🙃. You can assign any function that takes no arguments `()` and returns nothing `Void`
//: > 2. Before any function returns a value something can go wrong. To report back to the caller of the function that something went wrong you have 2 options:

//:     * `return nil` this is ok and very commen. But it does not explaine to the caller what the problem was.
//:            ** In our case we do not know for example that nil is returened because the json was missing a required key. In a product request this would be the case when we would delete `name` in the `jsonArray` data. Go ahead and try that out and see what is printed!
//:     * `throw` before the function can return `() throw -> Product`. A throw can be a descriptive error.
//:         * In the example below you can see this in action. A `DecodingError` is thrown with the case `keyMessing` and you can read which one. This is valuable and time saving debugging information.

service.perform([Product].self) { (resultFuntion) in
    do {
        let products = try resultFuntion()
        products.forEach { print("🚀 We have \($0)")}

    }
        //: Generic way to catch the error and inspect what is going wrong
    catch let error as ServiceError where error.decodingErrorMissingKey != nil {
        print("Error with missing key \\\(error.decodingErrorMissingKey!)")
    } catch {
        // ignore error
    }
}
//: > !Try to remove the name or points form `jsonArray` an see the error described.
//:> !! Faro also prints the errors so you should not do this in code !!!


//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)

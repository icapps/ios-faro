//: [Previous](@previous)


import UIKit
import Faro

//swiftlint:disable line_length

//: # Fetching Array from Service
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

struct Product: Decodable {
    let name: String
    let points: Int
    let description: String?
}

//: A service that will fetch product data needs a configuration to know the baseURL and a Session to be able to perform network requests.
//: * Session is derived from native `URLSession`
//: * Configuration is a simple object with some customizable baseURL's. You use it to switch between production or development service.
//: * Every service object is also linked to a specific *endpoint* example: `<baseURL>/products`. To define an endpoint we use an object called `Call`.
//: **Side note** we do not really do the a network request. We fetch the json from above. This can be done by using a `MockedSession`.
//: * *Data*: that is normaly returned from the service. Just change `MockedSession` -> `FaroSession` and this will work from any server.
//: * *Response*: A fake response is made that can have any statusCode. In this case we return with statusCode = 200 (this means OK in HTTP response code language).
let configuration = Configuration(baseURL: "http://www.yourServer.com")
let response = HTTPURLResponse(url: configuration.baseURL!, statusCode: 200, httpVersion: nil, headerFields: nil)
//: Create a session with a response OK (= 200) that returns the data of `jsonArray` above.
let session = MockSession(data: jsonArray, urlResponse: response, error: nil)
//: Now all we still need is a call that points to our endpoint. For example we take `/products`
let call = Call(path: "products")
let service = Service(call: call, autoStart: true, configuration: configuration, faroSession: session)
//: **AutoStart??** meand that whenever you use the function `perform` the request is imidiattaly fired. If you want to create multiple service instances and fire the request later put **autoStart** to false.
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

    } catch let error as FaroError where error.decodingErrorMissingKey != nil {
        print("Error with missing key \\\(error.decodingErrorMissingKey!)")
    } catch {
        // Any other error might be general
        print(error)
    }
}
//: > !Try to remove the name or points form `jsonArray` an see the error described.
//:> !! Faro also prints the errors so you should not do this in code !!!


//: [Next](@next)

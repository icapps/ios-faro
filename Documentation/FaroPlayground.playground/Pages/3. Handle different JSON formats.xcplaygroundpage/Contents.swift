//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
import Faro
/*:
 Depending on the data provider different json can be provided. Most of the cases are covered in Apples playground(see [Table of Contents](0.%20Table%20of%20Contents)).
 Here we disuss 2 common cases:
 1. The object to be decoded is nested in the JSON
 2. The naming of the keys is different

 More special cases can be handled by writing your own `Decoder`. See Apple docs for this.
 */
//: ## The object in to be decoded is nested in the JSON
/*:
 Many approaches are possible. We suggest to use a `Type` that mimics the nested json as an *intermediate* object.
 */

let jsonNested = """
{
  "products": [
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
}
""".data(using: .utf8)

class Product: Decodable, CustomDebugStringConvertible {
    let name: String
    let points: Int
    let description: String?

    var debugDescription: String {return "\nProduct(name: \(name)\npoints: \(points)\ndescription:\(description ?? "nil")\n"}
}
//: **Intermediate object**
struct ProductService: Decodable {
    let products: [Product]
}

let configuration = Configuration(baseURL: "http://www.yourServer.com")
let response = HTTPURLResponse(url: configuration.baseURL!, statusCode: 200, httpVersion: nil, headerFields: nil)
let session = MockSession(data: jsonNested, urlResponse: response, error: nil)
let call = Call(path: "products")
let service = Service(call: call, configuration: configuration, faroSession: session)

service.perform(ProductService.self) { print((try! $0()).products) }

/*:
 > **(try? $0())?** What is this. This is shoret hand notation for closures. The parameter that in the [Array example](1.%20Fetch%20Data%20from%20Array) was called `resultFunction` is now `$0`. The error that could be thrown is converted into `nil` with `try?`.
 */
/*:
> **Can we ignore the error** The error can be ignored because it is printed anyway. So if an error from the server does not result in a change in program flow you can just write this and ignore the error.
 */
//: ### Different naming in the keys used in received JSON

let jsonNestedRenamed = """
{
  "products": [
    {
      "key_name": "Banana",
      "key_points": 200,
      "key_description": "A banana grown in Ecuador."
    },
    {
      "key_name": "Orange",
      "key_points": 100
    }
  ]
}
""".data(using: .utf8)

class ProductRenamed: Product {

    private enum CodingKeys: String, CodingKey {
        case name = "key_name"
        case points = "key_points"
        case description = "key_description"
    }
}

struct ProductRenamedService: Decodable {
    let products: [ProductRenamed]
}

service.perform(ProductRenamedService.self) {
    print("--- Renamed ---")
    print(try! $0().products)
}

//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)

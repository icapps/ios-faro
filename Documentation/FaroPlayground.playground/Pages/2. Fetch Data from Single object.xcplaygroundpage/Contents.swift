//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
import Faro
/*:
 As we did most of the work before this this page will be short. You just have to change the type parameter!
 > `[Type].self` -> `Type.self` and interpret the result
 */

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
let service = Service(call: call, configuration: configuration, faroSession: session)

struct Product: Decodable {
    let name: String
    let points: Int
    let description: String?
}
service.perform(Product.self) {

    do {
        let product = try $0()
        print(product)
    } catch {
        print(error)
    }
}

//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)


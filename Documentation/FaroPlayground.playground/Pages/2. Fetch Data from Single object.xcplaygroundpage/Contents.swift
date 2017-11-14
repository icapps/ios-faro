//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
import Faro
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

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

let call = Call(path: "product")
let service = StubService(call: call)

call.stub(statusCode: 200, data: jsonSingle)

service.perform(Product.self) {
    let product = try? $0()
    print(product ?? "No product initialized correctly")
}

//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)


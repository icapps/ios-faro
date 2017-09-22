//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)

import Faro
//: # Write to the service
/*:
 It would be lame if we could not change some remote data. Depending on the data provider you choose they can respond with data or without data.
 */
//: ## Encode Product
struct Product: Encodable {
    let name: String
    let points: Int
}

let configuration = Configuration(baseURL: "http://www.yourServer.com")
let response = HTTPURLResponse(url: configuration.baseURL!, statusCode: 200, httpVersion: nil, headerFields: nil)
let session = MockSession(data: nil, urlResponse: response, error: nil)
//: What you write to the service will be in the body. In this case send with httpMethod 'POST' but 'PUT' or any other httpMethod is similar.
//: Change call to include your post
let product = Product(name: "Melon", points: 100)
let data = try! JSONEncoder().encode(product)
let call = Call(path: "products/\(product.name)", method: .POST, parameter:[.bodyData(data)])
let service = Service(call: call, configuration: configuration, faroSession: session)


//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)


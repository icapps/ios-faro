import Faro
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
//: # Write to the service
/*:
 It would be lame if we could not change some remote data. Depending on the data provider you choose they can respond with data or without data.
 */
StubbedFaroURLSession.setup()
//: ## Encode Product
struct Product: Encodable {
    let name: String
    let points: Int
    var encodedData: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    var jsonDict: [String: Any]? {
        guard let data = encodedData else {
            return nil
        }
        return try! JSONSerialization.jsonObject(with: data) as? [String: Any]
    }
}

//: Product encoding
let product = Product(name: "Melon", points: 100)
let parameters = [Parameter.jsonNode(product.jsonDict!)]
let call = Call(path: "products", method: .POST, parameter: parameters)
let service = Service(call: call)

call.stub(statusCode: 200, data: nil)

//: Use `Service.NoResponseData.self` as the type of the response. This is to allow no response data.
service.perform(Service.NoResponseData.self) { done in
    do {
        _ = try done()
        // Anyting after this will be executed on success
        print("🐦 message received!")
    } catch {}
}
/*:
 ---
 [Previous](@previous) / [Next](@next)
 */



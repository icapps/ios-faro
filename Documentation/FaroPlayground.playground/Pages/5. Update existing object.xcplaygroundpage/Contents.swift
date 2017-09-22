//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
import Faro
//: # Update an existing object
/*:
 Sometimes you want to update an existing object rather then create another instance in memory. Maybe you have property listeners that change the UI.
 > Wathever reason you might have note that updating is more complex and can be error prone. Immutable data should be prefered
 */
//: First we need an `Product that is not only `Decodable` but also `Updatable.
/*:
 Because we want to update an existing instance in memory only `class` types can be used. Other types are just immutable. Then we implement `Updatable`
 1. Update from a single model object
 2. Update from an array. It is your job to look for the model in the array and update yourself with its content
 3. Hashable, because we should be able to look an instance up in a set you should implement Hashable.
 */

class Product: Decodable, Updatable, CustomDebugStringConvertible {
    var name: String
    var points: Int
    var description: String?

    init(name: String, points: Int, description: String? = nil) {
        self.name = name
        self.points = points
        self.description = description
    }

    // MARK: - Updatable
    func update(_ model: AnyObject) throws {
        guard let model = model as? Product else {
            return
        }
        name = model.name
        points = model.points
        description = model.description
    }

    func update(array: [AnyObject]) throws {
        guard let array = array as? [Product] else {
            return
        }
        let set = Set(array)
        guard let model = (set.first {$0 == self} ) else {
            return
        }
        try update(model)
    }

    // MARK: - Hashable
    var hashValue: Int { return name.hashValue}

    public static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.name == rhs.name
    }

    var debugDescription: String { return "Product(name: \(name), points: \(points), description: \(description ?? "nil"))"}
}

//: ## Single object update

let jsonSingle = """
{
  "name": "Melon",
  "points": 100,
  "description": "Very orange and fruity!"
}
""".data(using: .utf8)!
var product = Product(name: "", points: -10)
//: Again provide a fake response:
let configuration = Configuration(baseURL: "http://www.yourServer.com")
let response = HTTPURLResponse(url: configuration.baseURL!, statusCode: 200, httpVersion: nil, headerFields: nil)
let session = MockSession(data: jsonSingle, urlResponse: response, error: nil)
//: *`/products` -> `/<name>`
let call = Call(path: "products/\(product.name)")
let service = Service(call: call, configuration: configuration, faroSession: session)

print("--- Single Update Before ---")
withUnsafePointer(to: &product) {
    print("\(product) has address: \($0)")
}
service.performUpdate(model: product) { update in
    do {
        try update()
        print("--- Single Update After ---")
        withUnsafePointer(to: &product) {
            print("\(product) has address: \($0)")
        }
    } catch {
        print(error)
        print("Product did not change \(product)")
    }
}

//: ## Array update

let productArray = [Product(name: "Melon", points: 10), Product(name: "Banana", points: 8)]

let jsonArray =  """
[
  {
    "name": "Melon",
    "points": 100,
    "description": "Very orange and fruity!"
  },
  {
    "name": "Banana",
    "points": 500,
    "description": "Very white and long"
  }
]
""".data(using: .utf8)!

let mockArraySession = MockSession(data: jsonArray, urlResponse: response, error: nil)
let arrayService = Service(call: call, configuration: configuration, faroSession: mockArraySession)

var firstProduct = productArray[0]
var secondProduct = productArray[1]

print("--- Array Update Before ---")
withUnsafePointer(to: &firstProduct) {
    print("Update Array first \(firstProduct) has address: \($0)")
}
withUnsafePointer(to: &secondProduct) {
    print("Update Array first \(secondProduct) has address: \($0)")
}
arrayService.performUpdate(array: productArray) {
    do {
        try $0()
        print("--- Array Update After ---")
        withUnsafePointer(to: &firstProduct) {
            print("Update Array first \(firstProduct) has address: \($0)")
        }
        withUnsafePointer(to: &secondProduct) {
            print("Update Array first \(secondProduct) has address: \($0)")
        }

    }catch {
        print(error)
    }
}
//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)

//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)
import Faro
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true
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

var product = Product(name: "Melon", points: -10)

let call = Call(path: "products/\(product.name)")
let path = call.path
call.stub(statusCode: 200, data:jsonSingle)
let service = StubService(call: call)

print("--- Single Update Before ---")
print("\(product)")

service.performUpdate(model: product) { update in
    try? update()
    print("--- Single Update After ---")
    print("\(product)")
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

let productsCall = Call(path: "products")
let arrayService = StubService(call: productsCall)

productsCall.stub(statusCode: 200, data: jsonArray)

var firstProduct = productArray[0]
var secondProduct = productArray[1]

print("--- Array Update Before ---")
print(firstProduct)
print(secondProduct)

arrayService.performUpdate(array: productArray) {
    try? $0()
    print("--- Array Update After ---")
    print(firstProduct)
    print(secondProduct)
}
//: [Table of Contents](0.%20Table%20of%20Contents)   [Previous](@previous) / [Next](@next)

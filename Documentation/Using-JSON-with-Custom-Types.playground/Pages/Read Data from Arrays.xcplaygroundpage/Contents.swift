/*:
[Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)
****
# Read Data From Arrays

When the JSON you use contains a homogeneous array of elements,
you add a conformance to the `Codable` protocol on the individual element's type.
To decode or encode the entire array, you use the syntax `[Element].self`.

In the example below, the `GroceryProduct` structure is automatically decodable
because the conformance to the `Codable` protocol is included in its declaration.
The whole array in the example is decodable based on the syntax used in the call
to the `decode` method.

*/
import Foundation

let jsonArray = """
[
    {
        "name": "Required name",
        "points": 200,
        "description": "A banana grown in Ecuador."
    },
    {
        "name": "Orange",
        "points": 100
    }
]
""".data(using: .utf8)!

let jsonSingle = """
{
        "name": "Required name",
        "points": 200,
        "description": "A banana grown in Ecuador."
}
""".data(using: .utf8)!

struct GroceryProduct: Codable {
    var name: String
    var points: Int
    var description: String?
}

let decoder = JSONDecoder()

// Array

do {
    let products = try decoder.decode([GroceryProduct].self, from: jsonArray)
    print("The following products are available:\n")

    for product in products {
        print("\t\(product.name) (\(product.points) points)")
        if let description = product.description {
            print("\t\t\(description)")
        }
    }
} catch {
    print("No products available because of error:\n\(error)")
}

// Single

do {
    let product = try decoder.decode(GroceryProduct.self, from: jsonSingle)
    print("The following products are available:\n")
    print("\t\(product.name) (\(product.points) points)")
    if let description = product.description {
        print("\t\t\(description)")
    }
} catch {
    print("No products available because of error:\n\(error)")
}

/*:
If the JSON array contains even one element that isn't a `GroceryProduct` instance,
the decoding fails.
This way, data isn't silently lost as a result of typos
or a misunderstanding of the guarantees made by the provider of the JSON array.
*/
//: [Table of Contents](Table%20of%20Contents) | [Previous](@previous) | [Next](@next)

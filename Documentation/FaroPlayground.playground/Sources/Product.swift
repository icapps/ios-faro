import Foundation

open class Product: Decodable, CustomDebugStringConvertible {
    public let name: String
    public let points: Int
    public let description: String?

    public init(name: String, points: Int, description: String?) {
        self.name = name
        self.points = points
        self.description = description
    }

    public var debugDescription: String {return "\nProduct(name: \(name)\npoints: \(points)\ndescription:\(description ?? "nil")\n"}

}

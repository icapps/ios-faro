import Foundation

public struct Product: Decodable {
    public let name: String
    public let points: Int
    public let description: String?
}

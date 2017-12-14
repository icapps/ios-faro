import Foundation
import Faro
import Stella

class PostServiceModel: Decodable {
    let posts: [Post]
}

struct Post: Decodable {
    let uuid: Int
    var title: String?

    private enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case title
    }
}

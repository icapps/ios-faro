import Foundation
import Faro
import Stella

class PostService: Decodable {
    let posts: [Post]
}

class Post: Decodable {
    let uuid: Int
    var title: String?

    private enum CodingKeys: String, CodingKey {
        case uuid = "id"
        case title
    }
}

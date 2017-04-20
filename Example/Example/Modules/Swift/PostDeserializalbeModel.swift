import Foundation
import Faro
import Stella

class Post: Deserializable {
    let uuid: Int
    var title: String?

    enum ServiceMap: String {
        case id, title
    }

    required init?(from raw: Any) {
        guard let json = raw as? [String: Any] else {
            return nil
        }
        do {
            self.uuid = try create(Post.ServiceMap.id.rawValue, from: json)
        } catch {
            printError("Error parsing Post with \(error).")
            return nil
        }

        // Not required variables

        title <-> json[.title]
    }

}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

    subscript (map: Post.ServiceMap) -> Value? {
        get {
            guard let key = map.rawValue as? Key else {
                return nil
            }

            let dict = self[key] as Value?
            return dict

        } set (newValue) {
            guard let newValue = newValue, let key = map.rawValue as? Key  else {
                return
            }

            self[key] = newValue
        }
    }

}

func transform(_ map: [Post.ServiceMap: Any]) -> [String: Any] {
    var result = [String: Any]()
    map.forEach { (dict:(key: Post.ServiceMap, value: Any)) in
        result[dict.key.rawValue] = dict.value
    }
    return result
}

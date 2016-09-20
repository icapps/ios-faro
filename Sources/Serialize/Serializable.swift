import Foundation

/// Serializes any `Type` into json.
public protocol Serializable {
    /// Get a json Dictionary back one level deep. Meaning we do not Parse relations.
    /// if you want your relations parsed implement `CustomSerializable`
    var json: [String: Any?] {get}

}

public protocol CustomSerializable: Serializable {
    func isRelation(for label: String) -> Bool
    func jsonForRelation(with key: String) -> JsonNode
}

//MARK: - Extension Serialize from model

public extension Serializable {
    /// Get a json Dictionary back one level deep. Meaning we do not Parse relations.
    /// if you want your relations parsed implement `CustomSerializable`
    public var json: [String: Any?] {
        get {
            if let customSelf = self as? CustomSerializable {
                var internalMap = [String: Any]()
                let mirror = Mirror(reflecting: self)
                for child in mirror.children where customSelf.isRelation(for: child.label!) == false{
                    internalMap[child.label!] = child.value
                }

                for child in mirror.children where customSelf.isRelation(for: child.label!) == true {
                    let relation = customSelf.jsonForRelation(with: child.label!)
                    switch relation {
                    case .nodeArray(let array):
                        internalMap[child.label!] = array
                    case .nodeObject(let object):
                        internalMap[child.label!] = object
                    default:
                        break
                    }
                }
                return internalMap
            } else {
                var internalMap = [String: Any]()
                let mirror = Mirror(reflecting: self)
                for child in mirror.children {
                    internalMap[child.label!] = child.value
                }
                return internalMap
            }
        }
    }
    
}

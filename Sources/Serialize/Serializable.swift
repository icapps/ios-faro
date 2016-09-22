import Foundation

/// Serializes any `Type` into json.
public protocol Serializable {
    /// Get a json Dictionary back one level deep. Meaning we do not Parse relations.
    /// if you want your relations parsed implement `CustomSerializable`
    var json: [String: Any?] {get}

}

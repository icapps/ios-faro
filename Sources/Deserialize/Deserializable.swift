import Foundation

/// Sets data on a class `Type`.
/// Unfortunatally it has to be a class because functions are mutating.
public protocol Deserializable: class {

    init?(from raw: Any)

    /// Each object should return a function that accepts `Any?`.
    /// Than function is used to set it to the corresponding property
    var mappers: [String : ((Any?)->())]? {get}
    
}

// MARK: Extension Deserialize from model

/// This maps `Any` type to the properties on anyone who is `Deserializable`.
/// You can override these if needed
public extension Deserializable {

    /// Uses `Mirror` to lookup a list of properties on your `Type`
    public func map(from raw: Any)  {
        guard let json = raw as? [String: Any] else {
            return
        }

        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            self[child.label!] = json[child.label!]
        }
    }

    /// Makes sure a `Deserializable` kan be used as a supscript
    public subscript(key: String) -> Any? {
        get {
            if let serializableSelf = self as? Serializable {
                return serializableSelf.json[key]
            } else {
                return nil
            }
        } set {
            guard let mapper = mappers?[key] else {
               return
            }

            mapper(newValue)
        }
    }
    
}

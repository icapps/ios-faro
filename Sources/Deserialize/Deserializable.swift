import Foundation

/// Sets data on a class `Type`.
public protocol Deserializable {

    init?(from raw: Any)
    
}

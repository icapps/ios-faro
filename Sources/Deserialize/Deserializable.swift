import Foundation

/// Sets data on a class `Type`.
/// Unfortunatally it has to be a class because functions are mutating.
public protocol Deserializable: class {

    init?(from raw: Any)
    
}

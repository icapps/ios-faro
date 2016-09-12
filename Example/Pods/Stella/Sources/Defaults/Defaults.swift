//
//  DefaultKeys.swift
//  Pods
//
//  Created by Jelle Vandebeeck on 08/06/16.
//
//

/// `Defaults` is a wrapper for the NSUserDefaults standard defaults instance.
public let Defaults = NSUserDefaults.standardUserDefaults()

/// `DefaultsKeys` is a wrapper we can extend to define all the different default keys available.
///
/// ```
/// extension DefaultsKeys {
///     static let string = DefaultsKey<String?>("the string defaults key")
/// }
/// ```
public class DefaultsKeys {}

/// The `DefaulesKey` defines the key and the value type for a certain user default value.
public class DefaultsKey<ValueType>: DefaultsKeys {
    private let key: String
    
    /// Initialize the key in your `DefaultsKeys` extension.
    ///
    /// ```
    /// static let string = DefaultsKey<String?>("the string defaults key")
    /// ```
    public init(_ key: String) {
        self.key = key
    }
}

public extension NSUserDefaults {
    
    /// Get the defaults String value for the given `DefaultsKey`. The preferred way to do this is to pass the static key variable defined in the `DefaultsKeys` extension.
    ///
    /// ```
    /// static let string = DefaultsKey<String?>("the string defaults key")
    /// ```
    public subscript(key: DefaultsKey<String?>) -> String? {
        get {
            return stringForKey(key.key)
        }
        set {
            setObject(newValue, forKey: key.key)
        }
    }
    
    /// Get the defaults Int value for the given `DefaultsKey`. The preferred way to do this is to pass the static key variable defined in the `DefaultsKeys` extension.
    ///
    /// ```
    /// static let integer = DefaultsKey<Int?>("the integer defaults key")
    /// ```
    public subscript(key: DefaultsKey<Int?>) -> Int? {
        get {
            return integerForKey(key.key)
        }
        set {
            if let newValue = newValue {
                setInteger(newValue, forKey: key.key)
            } else {
                removeObjectForKey(key.key)
            }
        }
    }
    
    /// Get the defaults Float value for the given `DefaultsKey`. The preferred way to do this is to pass the static key variable defined in the `DefaultsKeys` extension.
    ///
    /// ```
    /// static let float = DefaultsKey<Float?>("the float defaults key")
    /// ```
    public subscript(key: DefaultsKey<Float?>) -> Float? {
        get {
            return floatForKey(key.key)
        }
        set {
            if let newValue = newValue {
                setFloat(newValue, forKey: key.key)
            } else {
                removeObjectForKey(key.key)
            }
        }
    }
    
    /// Get the defaults Double value for the given `DefaultsKey`. The preferred way to do this is to pass the static key variable defined in the `DefaultsKeys` extension.
    ///
    /// ```
    /// static let double = DefaultsKey<Double?>("the double defaults key")
    /// ```
    public subscript(key: DefaultsKey<Double?>) -> Double? {
        get {
            return doubleForKey(key.key)
        }
        set {
            if let newValue = newValue {
                setDouble(newValue, forKey: key.key)
            } else {
                removeObjectForKey(key.key)
            }
        }
    }
    
    /// Get the defaults Bool value for the given `DefaultsKey`. The preferred way to do this is to pass the static key variable defined in the `DefaultsKeys` extension.
    ///
    /// ```
    /// static let boolean = DefaultsKey<Bool?>("the boolean defaults key")
    /// ```
    public subscript(key: DefaultsKey<Bool?>) -> Bool {
        get {
            return boolForKey(key.key) ?? false
        }
        set {
            setBool(newValue, forKey: key.key)
        }
    }
    
    /// Get the defaults NSDate value for the given `DefaultsKey`. The preferred way to do this is to pass the static key variable defined in the `DefaultsKeys` extension.
    ///
    /// ```
    /// static let date = DefaultsKey<NSDate?>("the date defaults key")
    /// ```
    public subscript(key: DefaultsKey<NSDate?>) -> NSDate? {
        get {
            return objectForKey(key.key) as? NSDate
        }
        set {
            setObject(newValue, forKey: key.key)
        }
    }
}
/**
Use this to print the type name
*/
public func typeName(some: Any) -> String {
	return (some is Any.Type) ? "\(some)" : "\(some.dynamicType)"
}

/**
Cast the argument to the infered function return type.

*/
public func autocast<T>(x: Any) -> T {
    return x as! T // tailor:disable
}

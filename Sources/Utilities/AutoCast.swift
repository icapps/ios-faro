//Casting when a protocol returns Self
//https://gist.github.com/werediver/3909c8cce93aeb28e1b2
//

/**
Use this to print the type name
*/
public func typeName(_ some: Any) -> String {
	return (some is Any.Type) ? "\(some)" : "\(type(of: (some) as Any))"
}

/**
Cast the argument to the infered function return type.

*/
public func autocast<T>(_ x: Any) -> T {
	return x as! T
}

protocol Foo {
	static func foo() -> Self
}

class Vehicle: Foo {
	class func foo() -> Self {
		return autocast(Vehicle())
	}
}

class Tractor: Vehicle {
	override class func foo() -> Self {
		return autocast(Tractor())
	}
}

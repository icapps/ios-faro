
var foo: String = "foo variable"

func fooFunc() -> String {
	return "Foo function"
}


func printFoo(_ foo: String) {
	print(foo)
}

// Kan elke functie printen die een string returned
func printFoo(fooFunction: () -> String) {
	print(fooFunction())
}

// Om de variable te printen doe je 

printFoo(foo)

// Je geeft de functie door zonder de ()
// dan werken ze gewoon als veraiable
printFoo(fooFunction: fooFunc)

// Een functie heeft het voordeel dat je iets als een vertaling of omvorming check zou kunnen doen

func printFooWithCheck(fooFunction: () -> String) {
	if foo == "foo variable" {
		print(fooFunction())
	} else {
		print("foo changed")
	}
}

printFooWithCheck(fooFunction: fooFunc)

foo = "something else"

// Uncomment deze laatste om het verschil te zien

//printFooWithCheck(fooFunction: fooFunc)


// Wat als je nu wil throwen?

enum FooError: Error {
	case noFooFound
}

func fooThrow() throws -> String {
	throw FooError.noFooFound
}

// print throw variant

func printFoo(fooFunction: () throws -> String) {
	do {
		print(try fooFunction())
	} catch {
		print(error)
	}
}

printFoo(fooFunction: fooThrow)



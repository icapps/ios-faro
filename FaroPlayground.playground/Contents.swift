//: Playground - noun: a place where people can play

import UIKit


class Foo {
    let bar = "value of bar"
    var blue: String? = "blue"
}

let foo = Foo()
let mirror = Mirror(reflecting: foo)

let children = mirror.children

for child in children {
    print(child.label)
}

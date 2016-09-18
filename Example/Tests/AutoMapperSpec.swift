import Quick
import Nimble

import Faro
@testable import Faro_Example

class Foo {
    var uuid: String?
    var blue: String?

    init(json: [String: Any]) {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            self[child.label!] = json[child.label!]
        }
    }

    subscript(key: String) -> Any? {
        get {
            return json[key]
        } set {
            if let mapper = mappers[key] {
                mapper(newValue)
            }
        }
    }

    /// Returns 
    var json: [String : Any?] {
        var internalMap = [String: Any?]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            internalMap[child.label!] = child.value
        }
        return internalMap
    }

    /// Each object should return a function that accepts `Any?`
    /// and uses it to set it to the corresponding property
    var mappers: [String : ((Any?)->())] {
        return ["uuid" : {value in self.uuid <- value },
                "blue" : {value in self.blue <- value }]
    }

}
class AutoMapperSpec: QuickSpec {

    override func spec() {
        describe("AutoMapperSpec") {

            context("Map JSON autoMagically") {

                let json = ["uuid": "id 1", "blue": "something"]
                let foo = Foo(json: json)

                it("should fill all properties") {
                    expect(foo.uuid).to(equal("id 1"))
                    expect(foo.blue).to(equal("something"))
                }

                it("should be subscriptable") {
                    let uuid = foo["uuid"] as! String?
                    let blue = foo["blue"] as! String?

                    expect(uuid).to(equal("id 1"))
                    expect(blue).to(equal("something"))
                }
            }
        }
    }

}

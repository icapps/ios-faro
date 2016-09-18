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
            return getMap()[key]
        } set {
            if key == "uuid" {
                uuid <- newValue
            } else if key == "blue" {
                blue <- newValue
            }
        }
    }

    func getMap() -> [String: Any?] {
        var internalMap = [String: Any?]()
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            internalMap[child.label!] = child.value
        }
        return internalMap
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

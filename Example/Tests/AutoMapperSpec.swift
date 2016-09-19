import Quick
import Nimble

import Faro
@testable import Faro_Example

class Foo: Parseable {
    var uuid: String?
    var blue: String?

    required init?(from raw: Any) {
        map(from: raw)
    }

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
                let foo = Foo(from: json)!
                foo.map(from: json)

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

import Quick
import Nimble

import Faro
@testable import Faro_Example

class Foo: Parseable {
    var uuid: String?
    var blue: String?
    var fooRelation: FooRelation?
    var relations: [FooRelation]?

    required init?(from raw: Any) {
        map(from: raw)
    }

    var mappers: [String : ((Any?)->())] {
        return ["uuid" : {self.uuid <- $0 },
                "blue" : {self.blue <- $0 },
                "fooRelation": {self.fooRelation = FooRelation(from: $0)},
                "relations": mapRelations()
                ]
    }

    private func mapRelations() -> (Any?)->() {
        return {[unowned self] in
            self.relations = serializeRelations(from: $0)
        }
    }

}

class FooRelation: Parseable {
    var uuid: String?

    required init?(from raw: Any) {
        map(from: raw)
    }

    var mappers: [String : ((Any?)->())] {
        return ["uuid": {self.uuid <- $0}]
    }


}

class ParseableSpec: QuickSpec {

    override func spec() {
        describe("Map JSON autoMagically") {

            context("No relations") {

                let json = ["uuid": "id 1", "blue": "something"]
                let foo = Foo(from: json)!

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

            context("One to one relation") {
                let relationId = "relation"
                let json = ["fooRelation": ["uuid": relationId]] as [String : Any]
                let foo = Foo(from: json)!

                it("should add relation") {
                    expect(foo.fooRelation).toNot(beNil())
                }

                it("should fill properties on relation") {
                    expect(foo.fooRelation?.uuid).to(equal(relationId))
                }
            }

            context("One to many relation") {
                let relationId = ["relation 1", "relation 2"]
                let relations =  [["uuid": relationId[0]], ["uuid": relationId[1]]]
                let json = ["relations": relations] as [String: Any]
                let foo = Foo(from: json)!

                it("should add relation") {
                    expect(foo.relations?.count).to(equal(2))
                }

                it("should fill properties on relation") {
                    expect(foo.relations![0].uuid).to(equal(relationId[0]))
                    expect(foo.relations![1].uuid).to(equal(relationId[1]))
                }

            }
        }
    }

}

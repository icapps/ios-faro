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
                "relations": addRelations()
                ]
    }

    private func addRelations() -> (Any?)->() {
        return {[unowned self] in
            self.relations = extractRelations(from: $0)
        }
    }

}

/// MARK: - CustomSerializalble

/// You do not have to implement this. But if you want to serialize relations you have to.
extension Foo: CustomSerializable {

    func isRelation(for label: String) -> Bool {
        let reations = ["fooRelation": true, "relations": true]
        let isRelation = reations[label]
        return isRelation != nil ? isRelation! : false
    }

    func jsonForRelation(with key: String) -> JsonNode {
        if key == "fooRelation" {
            guard let relation = fooRelation?.json else {
                return .nodeNotSerialized
            }
            return .nodeObject(relation)
        } else if key == "relations" {
            guard let relations = relations else {
                return .nodeNotSerialized
            }

            let jsonRelation = relations.map{ $0.json }
            return .nodeArray(jsonRelation)
        }

        return .nodeNotSerialized
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
            let uuidKey = "uuid"
            context("No relations") {
                let json = [uuidKey: "id 1", "blue": "something"]
                let foo = Foo(from: json)!

                it("should fill all properties") {
                    expect(foo.uuid).to(equal("id 1"))
                    expect(foo.blue).to(equal("something"))
                }

                it("should be subscriptable") {
                    let uuid = foo[uuidKey] as! String?
                    let blue = foo["blue"] as! String?

                    expect(uuid).to(equal("id 1"))
                    expect(blue).to(equal("something"))
                }

                context("serialize") {
                    let serializedFoo = foo.json
                    expect(serializedFoo[uuidKey] as! String?).to(equal("id 1"))
                    expect(serializedFoo["blue"] as! String?).to(equal("something"))
                }

            }

            context("One to one relation") {
                let relationId = "relation"
                let relationKey = "fooRelation"

                let json = [relationKey: [uuidKey: relationId]] as [String : Any]
                let foo = Foo(from: json)!

                it("should add relation") {
                    expect(foo.fooRelation).toNot(beNil())
                }

                it("should fill properties on relation") {
                    expect(foo.fooRelation?.uuid).to(equal(relationId))
                }

                context("serialize") {
                    let serializedFoo = foo.json
                    let fooRelation = serializedFoo[relationKey] as! [String: Any?]

                    expect(fooRelation[uuidKey]).toNot(beNil())
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

                context("serialize") {
                    let serializedFoo = foo.json
                    let relations = serializedFoo["relations"] as! [[String: Any?]]

                    expect(relations.count).to(equal(2))
                }
            }
        }
    }

}

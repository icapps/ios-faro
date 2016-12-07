import Quick
import Nimble

import Faro
@testable import Faro_Example

/// For testing with required variable
class Jail: Deserializable {
    var cellNumber: String
    var foodTicket: String?

    required init?(from raw: Any) {
        guard let json = raw as? [String: String] else {
            return nil
        }

        do {
            cellNumber = try parse("cellNumber", from: json)
        } catch {
            return nil
        }
        self.foodTicket <-> json["foodTicket"]
    }

}

class Zoo: Deserializable {
    var uuid: String?
    var color: String?
    var animal: Animal?
    var date: Date?
    var animalArray: [Animal]?

    required init?(from raw: Any) {
        guard let json = raw as? [String: Any] else {
            return nil
        }
        self.uuid <-> json["uuid"]
        self.color <-> json["color"]
        self.animal <-> json["animal"]
        self.animalArray <-> json["animalArray"]
        self.date <-> (json["date"], "yyyy-MM-dd")
    }
}

class Animal: Deserializable {
    var uuid: String?

    required init?(from raw: Any) {
        guard  let json = raw as? [String: Any] else {
            return nil
        }
        self.uuid <-> json["uuid"] as Any
    }

}

class DeserializableSpec: QuickSpec {

    override func spec() {
        describe("Deserialize JSON autoMagically") {
            let uuidKey = "uuid"
            context("No animalArray") {
                let json = [uuidKey: "id 1", "color": "something", "date": "2016-06-12"]
                let zoo = Zoo(from: json)!

                it("should fill all properties") {
                    expect(zoo.uuid) == "id 1"
                    expect(zoo.color) == "something"
                    expect(zoo.date).toNot(beNil())
                }
            }

            context("One to one relation") {
                let relationId = "relation"
                let relationKey = "animal"

                let json = [relationKey: [uuidKey: relationId]] as [String : Any]
                let zoo = Zoo(from: json)!

                it("should add relation") {
                    expect(zoo.animal).toNot(beNil())
                }

                it("should fill properties on relation") {
                    expect(zoo.animal?.uuid).to(equal(relationId))
                }


            }

            context("One to many relation") {
                let relationId = ["relation 1", "relation 2"]
                let animalArray =  [["uuid": relationId[0]], ["uuid": relationId[1]]]
                let json = ["animalArray": animalArray] as [String: Any]
                let zoo = Zoo(from: json)!

                it("should add relation") {
                    expect(zoo.animalArray?.count).to(equal(2))
                }

                it("should fill properties on relation") {
                    expect(zoo.animalArray![0].uuid).to(equal(relationId[0]))
                    expect(zoo.animalArray![1].uuid).to(equal(relationId[1]))
                }
            }

            context("required properties") {
                it("should parse required UUID") {
                    let gail = Jail(from: ["cellNumber": "007"])!

                    expect(gail.cellNumber) == "007"
                }

                it("should fail when no uuid provided") {
                    let gail = Jail(from: ["": ""])

                    expect(gail).to(beNil())
                }

                it("should automatically map optional parameters") {
                    let gail = Jail(from: ["cellNumber": "007", "foodTicket": "ticket"])!

                    expect(gail.foodTicket) == "ticket"
                }

                it("should not parse when json has keys but no uuid") {
                     let gail = Jail(from: ["foodTicket": "ticket"])

                    expect(gail).to(beNil())
                }
            }

        }
    }

}

import Quick
import Nimble

import Faro
@testable import Faro_Example

/// For testing with required variable
class Jail: JSONDeserializable, JSONUpdatable {
	var cellNumber: String
	var foodTicket: String?

	required init(_ raw: [String:Any]) throws {
		cellNumber  = try create("cellNumber", from: raw)
		foodTicket |< raw["foodTicket"]
	}

	func update(_ raw: [String: Any]) throws {
		try cellNumber |< raw["cellNumber"]
		foodTicket |< raw["foodTicket"]
	}

}

class Zoo: JSONDeserializable {
	var uuid: String?
	var color: String?
	var animal: Animal?
	var date: Date?
	var animalArray: [Animal]?

	required init(_ raw: [String: Any]) throws {
		self.uuid |< raw["uuid"]
		self.color |< raw["color"]
		self.date |< (raw["date"], "yyyy-MM-dd")

		// Create Deserializable models

		self.animal  = try? create("animal", from: raw)
		self.animalArray = try?  create("animalArray", from: raw)
	}
}

class Animal: JSONDeserializable, JSONUpdatable, Linkable, Hashable {

	public static func == (lhs: Animal, rhs: Animal) -> Bool {
		return lhs.hashValue == rhs.hashValue
	}

	typealias ValueType = String

	var uuid: String

	var hashValue: Int {
		return uuid.hashValue
	}

	var link: (key: String, value: String) {return (key: "uuid", value: uuid)}

	required init(_ raw: [String: Any]) throws {
		self.uuid = try create("uuid", from: raw)

	}

	func update(_ raw: [String: Any]) throws {
		try self.uuid |< json["uuid"]
	}

}

class DeserializableSpec: QuickSpec {

	override func spec() {
		describe("Deserialize JSON autoMagically") {
			let uuidKey = "uuid"
			context("No animalArray") {
				let json = [uuidKey: "id 1", "color": "something", "date": "2016-06-12"]

				it("should fill all properties") {
					expect {try Zoo(json).uuid} == "id 1"
					expect {try Zoo(json).color} == "something"
					expect {try Zoo(json).date}.toNot(beNil())
				}
			}

			context("One to one relation") {
				let relationId = "relation"
				let relationKey = "animal"

				let json = [relationKey: [uuidKey: relationId]] as [String : Any]

				it("should add relation") {
					expect {try Zoo(json).animal}.toNot(throwError())
				}

				fit("should fill properties on relation") {
					expect {try Zoo(json).animal?.uuid}.to(equal(relationId))
				}

			}

			context("One to many relation") {
				let relationId = ["relation 1", "relation 2"]
				let animalArray =  [["uuid": relationId[0]], ["uuid": relationId[1]]]
				let json = ["animalArray": animalArray] as [String: Any]

				it("should add relation") {
					expect {try Zoo(json).animalArray?.count}.to(equal(2))
				}

				it("should fill properties on relation") {
					expect {try Zoo(json).animalArray![0].uuid}.to(equal(relationId[0]))
					expect {try Zoo(json).animalArray![1].uuid}.to(equal(relationId[1]))
				}
			}

			context("required properties") {
				it("should create required UUID") {
					expect {try Jail(["cellNumber": "007"]).cellNumber} == "007"
				}

				it("should fail when no uuid provided") {
					expect {try Jail(["": ""])}.to(throwError())
				}

				it("should automatically map optional parameters") {
					expect { try Jail(["cellNumber": "007", "foodTicket": "ticket"]).foodTicket} == "ticket"
				}

				it("should not create when json has keys but no uuid") {
					expect {try Jail(["foodTicket": "ticket"])}.to(throwError())
				}
			}

		}
	}

}

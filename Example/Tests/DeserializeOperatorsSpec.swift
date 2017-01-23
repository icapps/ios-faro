import Quick
import Nimble

import Faro
@testable import Faro_Example

class Parent: Deserializable, Updatable, Linkable {
	typealias ValueType = String

	var uuid: String
	var relation: DeserializableObject
	var tooMany = [DeserializableObject]()

	// MARK: - Linkable
	var link: (key: String, value: String) { return (key: "uuid", value: uuid) }

	required init?(from raw: Any) {
		// Temp values are required because swift needs initialization
		uuid = ""
		relation = DeserializableObject()

		do {
			try update(from: raw)
		} catch {
			print(error)
			return nil
		}
	}

	func update(from raw: Any) throws {
		guard let json = raw as? [String: Any] else {
			throw FaroDeserializableError.wrongJSON(raw)
		}
		try uuid <-> json["uuid"]
		try relation <-> json["relation"]
		try relation <-> json["tooMany"]
	}

}
class DeserializableObject: Deserializable, Updatable, Linkable {
	typealias ValueType = String

    var uuid: String
    var amount: Int?
    var price: Double?
    var tapped: Bool?
    var date: Date?

	// MARK: - Linkable
	var link: (key: String, value: String) { return (key: "uuid", value: uuid) }

	convenience init () {
		self.init(from: ["uuid": UUID().uuidString])!
	}

    required init?(from raw: Any) {
		uuid = UUID().uuidString
		do {
			try update(from: raw)
		} catch {
			print(error)
			return nil
		}

    }

	func update(from raw: Any) throws {
		guard let json = raw as? [String: Any] else {
			throw FaroDeserializableError.wrongJSON(raw)
		}

		try self.uuid <-> json["uuid"]
		self.amount <-> json["amount"]
		self.price <-> json["price"]
		self.tapped <-> json["tapped"]
		self.date <-> (json["date"], "yyyy-MM-dd")
	}

}

class DeserializeOperatorsSpec: QuickSpec {

    override func spec() {
        describe("DeserializeOperatorsSpec") {
            let testAny = ["uuid": "some id", "amount": 20, "price": 5.0, "tapped": true, "date": "1994-08-20"] as Any?
			guard let json = testAny as? [String: Any] else {
				XCTFail()
				return
			}

            context("should give value for") {
                it("should work for relations") {
                    let relationId = ["relation 1", "relation 2"]
                    let animalArray =  [["uuid": relationId[0]], ["uuid": relationId[1]]]
                    let json = ["animalArray": animalArray] as Any?

                    var zoo = Zoo(from: ["": ""])

                    zoo <-> json

                    expect(zoo?.animalArray?.count) == 2
                }

                it("should deserialize from object") {
                    let randomNumber = "randomNumber"
                    let json = ["cellNumber": randomNumber, "foodTicket": "ticket"] as Any?

                    var gail = Jail(from: ["": ""])

                    gail <-> json

                    expect(gail?.cellNumber) == randomNumber

                }

                it("should deserialize from object Array") {
                    let json = [["uuid": "id1"], ["uuid": "id2"]] as Any?
                    var animalArray: [Animal]?

                    animalArray <-> json

                    expect(animalArray?.count) == 2
                }

				context("Primitive types on object") {
					var o1: DeserializableObject!

					beforeEach {
						 o1 = DeserializableObject()
					}

					it("Int") {
						o1.amount <-> json["amount"]

						expect(o1.amount) == json["amount"] as? Int
					}

					it("Double") {
						o1.price <-> json["price"]

						expect(o1?.price) == json["price"] as? Double
					}

					it("Bool") {
						o1?.tapped <-> json["tapped"]

						expect(o1?.tapped) == json["tapped"] as? Bool
					}

					it("String") {
						expect {
							try o1.uuid <-> json["uuid"]

							return expect(o1?.uuid) == json["uuid"] as? String
						}.toNot(throwError())
					}

					context("Date") {

						it("String in json") {
							o1.date <-> (json["date"], "yyyy-MM-dd")

							let formatter = DateFormatter()
							formatter.dateFormat = "yyyy-MM-dd"
							let currentDate = formatter.date(from: "1994-08-20")

							expect(o1.date) == currentDate

						}

						it("TimeInterval") {

							let anyTimeInterval: TimeInterval = 1234.0

							o1.date <-> anyTimeInterval

							let date = Date(timeIntervalSince1970: anyTimeInterval)
							expect(o1.date) == date
						}

						it("String") {
							o1.date <-> ("1994-08-20" as Any?, "yyyy-MM-dd")

							let formatter = DateFormatter()
							formatter.dateFormat = "yyyy-MM-dd"
							let currentDate = formatter.date(from: "1994-08-20")

							expect(o1.date) == currentDate
						}
					}
				}

            }

			fcontext("Update") {
				var relationDict: [String: Any] = ["uuid": "relation id", "amount": 20, "price": 5.0, "tapped": true, "date": "1994-08-20"]
				var updateAny: [String: Any] = ["uuid": "route id", "relation": relationDict]

				var tooMany = [[String: Any]]()
				for i in 0..<3 {
					relationDict["uuid"] = "uuid \(i)"
					tooMany.append(relationDict)
				}
				updateAny["tooMany"] = tooMany

				it("updates existing object") {
					let parent = Parent(from: updateAny as Any)

					expect(parent?.uuid) == "route id"
					expect(parent?.relation.uuid) == "relation id"
					expect(parent?.relation.amount) == 20
					expect(parent?.relation.price) == 5.0
					expect(parent?.relation.tapped) == true
					expect(parent?.relation.date).toNot(beNil())

					let initialRelation = parent?.relation
					try? parent?.update(from: updateAny)

					expect(parent?.relation) === initialRelation
				}

				context("too many") {


				}
			}
        }
    }

}

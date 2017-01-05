import Quick
import Nimble

import Faro
@testable import Faro_Example

enum RawInt: Int {
	case zero, one
}

enum RawString: String {
	case first, second
}

class DeserializeFunctionSpec: QuickSpec {

    override func spec() {
        describe("DeserializeFunctionSpec") {

			context("should parse form JSON") {

				context("Values") {

					it("Any value") {
						let uuidKey = "uuid"
						let json = [uuidKey:"some id" as Any]
						let o1 = DeserializableObject(from: ["":""])!

						o1.uuid = try! parse(uuidKey, from: json)

						expect(o1.uuid) == json["uuid"] as? String
					}

					context("RawRepresentable") {

						context("No throw") {

							it("Int") {
								expect {
									let foo: RawInt = try parse("rawInt", from: ["rawInt": 0])
									return expect(foo.rawValue) == RawInt.zero.rawValue
									}.toNot(throwError())
							}

							it("String") {
								expect {
									let foo: RawString = try parse("rawInt", from: ["rawInt": "first"])
									return expect(foo.rawValue) == RawString.first.rawValue
									}.toNot(throwError())
							}

						}

						context("Throw") {

							it("Int") {
								expect {
									let _: RawInt = try parse("rawInt", from: ["rawInt": 10])
									return false
								}.to(throwError())
							}

							it("String") {
								expect {
									let _: RawString = try parse("rawInt", from: ["rawInt": "unknown"])
									return false
								}.to(throwError())
							}
						}

					}

				}

				context ("Date") {

					it("has TimeInterval") {
						let dateKey = "date"
						let dateTimeInterval: TimeInterval = 12345.0
						let json = ["date": dateTimeInterval]
						let o1 = DeserializableObject(from: ["":""])!

						o1.date = try! parse(dateKey, from: json)

						let date = Date(timeIntervalSince1970: json["date"]!)
						expect(o1.date) == date
					}

					it("has String") {
						let dateKey = "date"
						let dateString = "1994-08-20"
						let json = [dateKey: dateString as Any]
						let o1 = DeserializableObject(from: ["":""])!

						o1.date = try! parse(dateKey, from: json, format: "yyyy-MM-dd")

						expect(o1.date).toNot(beNil())
					}

				}

				context("Object") {

					it("single") {
						let dict: [String: Any] = ["uuid":"some id"]
						let json: [String: Any] = ["node": dict]

						let o1: DeserializableObject = try! parse("node", from: json)

						expect(o1.uuid) == "some id"
					}

					it("collection") {
						let dict1 = ["uuid": "id1"]
						let dict2 = ["uuid":"id2"]
						let json: [String: Any] = ["node": [dict1, dict2]]


						let objectArray: [DeserializableObject] = try! parse("node", from: json)

						expect(objectArray.count) == 2
						expect(objectArray.first?.uuid) == "id1"
						expect(objectArray.last?.uuid) == "id2"
					}
				}


			}

        }
    }

}

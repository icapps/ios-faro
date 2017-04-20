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
						let json = [uuidKey: "some id" as Any]
						let o1 = DeserializableObject(from: ["": ""])!

						expect {
							o1.uuid = try create(uuidKey, from: json)

							return expect(o1.uuid) == json["uuid"] as? String
						}.toNot(throwError())

					}

					context("RawRepresentable") {

						context("No throw") {

							it("Int") {
								expect {
									let foo: RawInt = try create("rawInt", from: ["rawInt": 0])
									return expect(foo.rawValue) == RawInt.zero.rawValue
									}.toNot(throwError())
							}

							it("String") {
								expect {
									let foo: RawString = try create("rawInt", from: ["rawInt": "first"])
									return expect(foo.rawValue) == RawString.first.rawValue
									}.toNot(throwError())
							}

						}

						context("Throw") {

							it("Int") {
								expect {
									let _: RawInt = try create("rawInt", from: ["rawInt": 10])
									return false
								}.to(throwError())
							}

							it("String") {
								expect {
									let _: RawString = try create("rawInt", from: ["rawInt": "unknown"])
									return false
								}.to(throwError())
							}
						}

					}

				}

				context ("Date") {

					fit("has TimeInterval") {
						let dateKey = "date"
						let dateTimeInterval: TimeInterval = 12345.0
						let json = ["date": dateTimeInterval]
						let o1 = DeserializableObject(from: ["": ""])!

						expect {
							o1.date = try create(dateKey, from: json)

							let date = Date(timeIntervalSince1970: json["date"]!)
							return expect(o1.date) == date
						}.toNot(throwError())

					}

					it("has String") {
						let dateKey = "date"
						let dateString = "1994-08-20"
						let json = [dateKey: dateString as Any]
						let o1 = DeserializableObject(from: ["": ""])

						expect {
							o1?.date = try create(dateKey, from: json, format: "yyyy-MM-dd")

							return expect(o1?.date).toNot(beNil())
						}.toNot(throwError())
					}

				}

				context("Object") {

					it("single") {
						let dict: [String: Any] = ["uuid": "some id"]
						let json: [String: Any] = ["node": dict]

						expect {
							let o1: DeserializableObject = try create("node", from: json)

							return expect(o1.uuid) == "some id"
						}.toNot(throwError())

					}

					it("collection") {
						let dict1 = ["uuid": "id1"]
						let dict2 = ["uuid": "id2"]
						let json: [String: Any] = ["node": [dict1, dict2]]

						expect {
							let objectArray: [DeserializableObject] = try create("node", from: json)

							expect(objectArray.count) == 2
							expect(objectArray.first?.uuid) == "id1"
							return expect(objectArray.last?.uuid) == "id2"
						}.toNot(throwError())

					}
				}

			}

        }
    }

}

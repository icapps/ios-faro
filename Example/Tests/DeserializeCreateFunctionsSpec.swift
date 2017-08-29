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

class DeserializeCreateFunctionSpec: QuickSpec {

    override func spec() {
		describe("Primitive types") {

			it("Any value") {
				let uuidKey = "uuid"
				let json = [uuidKey: "some id" as Any]

				expect {
					let uuid: String = try create(uuidKey, from: json)

					return expect(uuid) == json["uuid"] as? String
					}.toNot(throwError())

			}

			it("Array of Strings - works for any type") {

				expect {try create("key", from: ["key": ["String", "String 2"]])} == ["String", "String 2"]
			}

			it("Set of Strings - works for any type") {

				expect {
					let set: Set<String> = try create("key", from: ["key": ["String", "String 2"]])
					let array = Array(set)
					expect(array.sorted(by: >)) == ["String 2", "String"]
					return true
				}.toNot(throwError())
			}

		}

		describe("Date") {

			it("has TimeInterval") {
				let dateKey = "date"
				let dateTimeInterval: TimeInterval = 12345.0
				let json = ["date": dateTimeInterval]

				expect {
					let result: Date = try create(dateKey, from: json)

					let date = Date(timeIntervalSince1970: json["date"]!)
					return expect(result) == date
					}.toNot(throwError())

			}

			it("has String") {
				let dateKey = "date"
				let dateString = "1994-08-20"
				let json = [dateKey: dateString as Any]

				expect {
					let result: Date = try create(dateKey, from: json, format: "yyyy-MM-dd")

					return expect(result).toNot(beNil())
					}.toNot(throwError())
			}

		}

		describe("Object") {

			it("single") {
				let dict: [String: Any] = ["uuid": "some id", "date": "1984-01-14"]
				let json: [String: Any] = ["node": dict]

				expect {
					let o1: DeserializableObject = try create("node", from: json)

					return expect(o1.uuid) == "some id"
					}.toNot(throwError())

			}

			it("collection") {
				let dict1 = ["uuid": "id1", "date": "1984-01-14"]
				let dict2 = ["uuid": "id2", "date": "1984-01-14"]
				let json: [String: Any] = ["node": [dict1, dict2]]

				expect {
					let objectArray: [DeserializableObject] = try create("node", from: json)

					expect(objectArray.count) == 2
					expect(objectArray.first?.uuid) == "id1"
					return expect(objectArray.last?.uuid) == "id2"
					}.toNot(throwError())

			}
		}

		describe("RawRepresentables") {

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

			it("Parses Array of Strings - or any other RawRepresentable") {
				let strings: [StringEnum]? = try? create("strings", from: ["strings": ["first", "second"]])
				expect(strings) == [.first, .second]
			}

			it("Parses Set of Strings - or any other RawRepresentable") {
				let strings: Set<StringEnum>? = try? create("strings", from: ["strings": ["first", "second"]])
				expect(strings) == [.first, .second]
			}

		}
    }

}

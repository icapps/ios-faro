import Quick
import Nimble

import Faro
@testable import Faro_Example

class DeserializeFunctionSpec: QuickSpec {

    override func spec() {
        describe("DeserializeFunctionSpec") {

            it("should parse generic value from JSON") {
                let uuidKey = "uuid"
                let json = [uuidKey: "some id" as Any]
                let o1 = DeserializableObject(from: ["": ""])!

				expect {
					o1.uuid = try parse(uuidKey, from: json)
					return expect(o1.uuid) == json["uuid"] as? String
				}.toNot(throwError())

            }

            it("should parse Date from JSON with TimeInterval") {
                let dateKey = "date"
                let dateTimeInterval: TimeInterval = 12345.0
                let json = ["date": dateTimeInterval]
                let o1 = DeserializableObject(from: ["": ""])!

				expect {
					o1.date = try parse(dateKey, from: json)

					let date = Date(timeIntervalSince1970: json["date"]!)
					return expect(o1.date) == date
				}.toNot(throwError())

            }

            it("should parse Date from JSON with String") {
                let dateKey = "date"
                let dateString = "1994-08-20"
                let json = [dateKey: dateString as Any]
				expect {
					let o1 = DeserializableObject(from: ["": ""])!

					o1.date = try parse(dateKey, from: json, format: "yyyy-MM-dd")

					return expect(o1.date).toNot(beNil())
				}.toNot(throwError())

            }

            it("should parse generic object from JSON") {
                let dict: [String: Any] = ["uuid": "some id"]
                let json: [String: Any] = ["node": dict]

				expect {
					let o1: DeserializableObject = try parse("node", from: json)

					return expect(o1.uuid) == "some id"
				}.toNot(throwError())

            }

            it("should parse generic object arrays from JSON") {
                let dict1 = ["uuid": "id1"]
                let dict2 = ["uuid": "id2"]
                let json: [String: Any] = ["node": [dict1, dict2]]

				expect {
					let objectArray: [DeserializableObject] = try parse("node", from: json)

					expect(objectArray.count) == 2
					expect(objectArray.first?.uuid) == "id1"
					return expect(objectArray.last?.uuid) == "id2"
				}.toNot(throwError())

            }

        }
    }

}

import Quick
import Nimble

import Faro
@testable import Faro_Example

class DeserializeFunctionSpec: QuickSpec {

    override func spec() {
        describe("DeserializeFunctionSpec") {

            it("should parse generic value from JSON") {
                let uuidKey = "uuid"
                let json = [uuidKey:"some id" as Any]
                let o1 = DeserializableObject(from: ["":""])!

                o1.uuid = try! parse(uuidKey, from: json)

                expect(o1.uuid) == json["uuid"] as? String
            }

            it("should parse Date from JSON with TimeInterval") {
                let dateKey = "date"
                let dateTimeInterval: TimeInterval = 12345.0
                let json = ["date": dateTimeInterval]
                let o1 = DeserializableObject(from: ["":""])!

                o1.date = try! parse(dateKey, from: json)

                let date = Date(timeIntervalSince1970: json["date"]!)
                expect(o1.date) == date
            }

            it("should parse Date from JSON with String") {
                let dateKey = "date"
                let dateString = "1994-08-20"
                let json = [dateKey: dateString as Any]
                let o1 = DeserializableObject(from: ["":""])!

                o1.date = try! parse(dateKey, from: json, format: "yyyy-MM-dd")

                expect(o1.date).toNot(beNil())
            }

            it("should parse generic object from JSON") {
                let dict: [String: Any] = ["uuid":"some id"]
                let json: [String: Any] = ["node": dict]

                let o1: DeserializableObject = try! parse("node", from: json)

                expect(o1.uuid) == "some id"
            }

            it("should parse generic object arrays from JSON") {
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


import Quick
import Nimble

import Faro
@testable import Faro_Example

class SerializableObject: Serializable {
    var uuid: String?
}

class SerializeOpereratorsSpec: QuickSpec {

    override func spec() {
        describe("SerializeOpereratorsSpec") {

            it("should serialize to JSON object") {
                var serializedDictionary: Any?
                let o1 = SerializableObject()
                o1.uuid = "ID1"

                serializedDictionary <- o1

                let dict = serializedDictionary as! [String: String]

                expect(dict["uuid"]) == o1.uuid
            }

            it("should serialize to JSON array") {
                var serializedDictionary: Any?
                let o1 = SerializableObject()
                o1.uuid = "ID1"
                let o2 = SerializableObject()
                o2.uuid = "ID2"

                serializedDictionary <- [o1, o2]

                let dictArray = serializedDictionary as! [[String: String]]

                expect(dictArray.count) == 2
                expect(dictArray.first!["uuid"]) == o1.uuid
                expect(dictArray.last!["uuid"]) == o2.uuid

            }

        }
    }
    
}


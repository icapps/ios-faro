import Quick
import Nimble

import Faro
@testable import Faro_Example

class DeserializeFunctionSpec: QuickSpec {

    override func spec() {
        describe("DeserializeFunctionSpec") {

            it("should parse JSON") {
                let o1 = DeserializableObject(from: ["":""])
                o1?.uuid = "id1"
                o1?.amount = 20
                
                var parsedJson: [String: Any] {
                    return parse({ (json) in
                        json["id"] <-> o1?.uuid
                        json["amount"] <-> o1?.amount
                    })
                }
                
                expect(parsedJson.count) == 2
                expect(parsedJson["id"] as? String) == o1?.uuid
                expect(parsedJson["amount"] as? Int) == o1?.amount
            }
            
            it("should parse generic value from JSON") {
                let uuidKey = "uuid"
                let json = [uuidKey:"some id"] as [String : Any]
                let o1 = DeserializableObject(from: ["":""])
                
                do {
                    o1?.uuid = try parse(uuidKey, from: json)
                } catch {
                    return
                }
                
                expect(o1?.uuid) == json["uuid"] as? String
            }
            
            it("should parse Date from JSON with TimeInterval") {
                let dateKey = "date"
                let dateTimeInterval: TimeInterval = 12345.0
                let json = ["date": dateTimeInterval]
                let o1 = DeserializableObject(from: ["":""])
                
                do {
                    o1?.date = try parse(dateKey, from: json)
                } catch {
                    return
                }
                
                let date = Date(timeIntervalSince1970: json["date"]!)
                expect(o1?.date) == date
            }
            
            it("should parse Date from JSON with String") {
                let dateKey = "date"
                let dateString = "1994-08-20"
                let json = ["date": dateString]
                let o1 = DeserializableObject(from: ["":""])
                
                do {
                    setDateFormat("yyyy-MM-dd")
                    o1?.date = try parse(dateKey, from: json)
                } catch {
                    return
                }
                
                expect(o1?.date).toNot(beNil())
            }
            
            it("should parse generic object from JSON") {
                let json = ["uuid":"some id"] as [String: Any]
                var o1 = DeserializableObject(from: ["":""])
                
                do {
                    o1 = try parse(from: json)
                } catch {
                    return
                }
                
                expect(o1?.uuid) == json["uuid"] as! String?
            }
            
            it("should parse generic object arrays from JSON") {
                let json = [["uuid": "id1"],["uuid":"id2"]]
                let o1 = DeserializableObject(from: ["":""])
                let o2 = DeserializableObject(from: ["":""])
                var objectArray = [o1!, o2!]
                
                do {
                    objectArray = try parse(from: json)!
                } catch {
                    return
                }
            
                expect(objectArray.count) == 2
                expect(objectArray.first?.uuid) == json.first?["uuid"]
                expect(objectArray.last?.uuid) == json.last?["uuid"]
            }
        }
    }
    
}

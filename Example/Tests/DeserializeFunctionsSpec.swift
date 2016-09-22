import Quick
import Nimble

import Faro
@testable import Faro_Example

class DeserializeFunctionSpec: QuickSpec {

    override func spec() {
        describe("DeserializeFunctionSpec") {

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
        }
    }
    
}

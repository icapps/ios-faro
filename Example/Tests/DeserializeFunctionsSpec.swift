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
            }
        }
    }
    
}

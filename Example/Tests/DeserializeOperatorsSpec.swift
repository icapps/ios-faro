import Quick
import Nimble

import Faro
@testable import Faro_Example

class DeserializableObject: Deserializable {
    var uuid: String?
    var amount: Int?
    var price: Double?
    var tapped: Bool?
    var date: Date?
    
    required init?(from raw: Any) {
        map(from: raw)
    }
    
    var mappers: [String : ((Any?) -> ())] {
        get {
            return [
                "uuid": {self.uuid <-> $0},
                "amount": {self.amount <-> $0},
                "price": {self.price <-> $0},
                "tapped": {self.tapped <-> $0},
                "date": {self.date <-> $0}
            ]
        }
    }

}
class DeserializeOperatorsSpec: QuickSpec {

    override func spec() {
        describe("DeserializeOperatorsSpec") {

            context("should give value for") {
                it("should work for relations") {
                    let relationId = ["relation 1", "relation 2"]
                    let animalArray =  [["uuid": relationId[0]], ["uuid": relationId[1]]]

                    let json = ["animalArray": animalArray] as Any?

                    var zoo = Zoo(from: ["":""])

                    zoo <-> json

                    expect(zoo?.animalArray?.count) == 2
                }
                
                it("should deserialize to object") {
                    let randomNumber = "randomNumber"
                    let json = ["cellNumber": randomNumber, "foodTicket": "ticket"] as Any?
                    
                    var gail = Gail(from: ["":""])
                    
                    gail <-> json
                    
                    expect(gail?.cellNumber) == randomNumber
                    
                }
                
                it("should deserialize to object Array") {
                    let json = [["uuid": "id1"],["uuid": "id2"]] as Any?
                    var animalArray: [Animal]?
                    
                    animalArray <-> json
                    
                    expect(animalArray?.count) == 2
                }
                
                it("should deserialize Integers") {
                    let o1 = DeserializableObject(from: ["": ""])
                    let anyInt = 10 as Any?
                    
                    o1?.amount <-> anyInt
                    
                    expect(o1?.amount) == anyInt as! Int?
                }
                
                it("should deserialize Doubles") {
                    let o1 = DeserializableObject(from: ["":""])
                    let anyDouble = 5.0 as Any?
                    
                    o1?.price <-> anyDouble
                    
                    expect(o1?.price) == anyDouble as! Double?
                }
                
                it("should deserialize Booleans") {
                    let o1 = DeserializableObject(from: ["":""])
                    let anyBool = true as Any?
                    
                    o1?.tapped <-> anyBool
                    
                    expect(o1?.tapped) == anyBool as! Bool?
                }
                
                it("should deserialize Strings") {
                    let o1 = DeserializableObject(from: ["":""])
                    let anyString = "randomID" as Any?
                    
                    o1?.uuid <-> anyString
                    
                    expect(o1?.uuid) == anyString as! String?
                }
                
                it("should deserialize Date with TimeInterval") {
                    let o1 = DeserializableObject(from: ["":""])
                    let anyTimeInterval = 1234.0 as Any?
                    
                    o1?.date <-> anyTimeInterval
                    
                    let date = Date(timeIntervalSince1970: anyTimeInterval as! TimeInterval)
                    expect(o1?.date) == date
                }
                
                it("should deserialize Date with String") {
                    let o1 = DeserializableObject(from: ["":""])
                    let anyTimeString = "20-08-1994" as Any?
                    
                    o1?.date <-> anyTimeString
                    
                    let formatter = DateFormatter()
                    let date = formatter.date(from: anyTimeString as! String)
                    
                    expect(o1?.date) == date
                    
                }
            }
        }
    }
    
}

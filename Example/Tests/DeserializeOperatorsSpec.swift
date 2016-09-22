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
    
    var mappers: [String : ((Any?) -> ())]? {
        get {
            return [
                "uuid": {self.uuid <-> $0},
                "amount": {self.amount <-> $0},
                "price": {self.price <-> $0},
                "tapped": {self.tapped <-> $0},
                "date": {self.date <-> ($0, "yyyy-MM-dd")}
            ]
        }
    }

}

class DeserializeOperatorsSpec: QuickSpec {
    
    let testJson = ["uuid": "some id", "amount": 20, "price": 5.0, "tapped": true, "date": "1994-08-20"] as Any?
    
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
                    guard let json = self.testJson as? [String: Any] else {
                        return
                    }
                    
                    o1?.amount <-> json["amount"]
                    
                    expect(o1?.amount) == json["amount"] as! Int?
                }
                
                it("should deserialize Doubles") {
                    let o1 = DeserializableObject(from: ["":""])
                    guard let json = self.testJson as? [String: Any] else {
                        return
                    }
                    
                    o1?.price <-> json["price"]
                    
                    expect(o1?.price) == json["price"] as! Double?
                }
                
                it("should deserialize Booleans") {
                    let o1 = DeserializableObject(from: ["":""])
                    guard let json = self.testJson as? [String: Any] else {
                        return
                    }
                    
                    o1?.tapped <-> json["tapped"]
                    
                    expect(o1?.tapped) == json["tapped"] as! Bool?
                }
                
                it("should deserialize Strings") {
                    let o1 = DeserializableObject(from: ["":""])
                    guard let json = self.testJson as? [String: Any] else {
                        return
                    }
                    
                    o1?.uuid <-> json["uuid"]
                    
                    expect(o1?.uuid) == json["uuid"] as! String?
                }
                
                it("should deserialize Date with String") {
                    let o1 = DeserializableObject(from: ["":""])
                    let timeString = "1994-08-20" as String?
                    
                    /// Don't forget to set the date format by calling setDateFormat(_format: String)
                    setDateFormat("yyyy-MM-dd")
                    
                    o1?.date <-> timeString
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let currentDate = formatter.date(from: timeString!)
                    
                    expect(o1?.date).toNot(beNil())
                    expect(o1?.date) == currentDate
                    
                }
                
                it("should deserialize Date with TimeInterval") {
                    let o1 = DeserializableObject(from: ["":""])
                    let anyTimeInterval = 1234.0 as TimeInterval?
                    
                    o1?.date <-> anyTimeInterval
                    
                    let date = Date(timeIntervalSince1970: anyTimeInterval!)
                    expect(o1?.date) == date
                }
                
                it("should deserialize Date with json and String") {
                    let o1 = DeserializableObject(from: ["":""])
                    let timeString = "yyyy-MM-dd"
                    
                    let json1 = ["date": "1994-08-20"] as Any?
                    guard let json = json1 as? [String: Any] else {
                        return
                    }
                    
                    let rhs = (json["date"], timeString)
                    
                    o1?.date <-> rhs
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let currentDate = formatter.date(from: "1994-08-20")
                    
                    expect(o1?.date).toNot(beNil())
                    expect(o1?.date) == currentDate
                    
                }
            }
        }
    }
    
}

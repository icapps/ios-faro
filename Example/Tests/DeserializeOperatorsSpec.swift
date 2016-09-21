import Quick
import Nimble

import Faro
@testable import Faro_Example

class DeserializableObject: Deserializable {
    var uuid: String?
    var amount: Int?
    var price: Double?
    
    required init?(from raw: Any) {
        map(from: raw)
    }
    
    var mappers: [String : ((Any?) -> ())] {
        get {
            return [
                "uuid": {self.uuid <-> $0},
                "amount": {self.amount <-> $0},
                "price": {self.price <-> $0}
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
                    let o1 = DeserializableObject(from: ["amount": 5])
                    let anyInt = 10 as Any?
                    
                    o1?.amount <-> anyInt
                    
                    expect(o1?.amount) == anyInt as! Int?
                }
                
                it("should deserialize Doubles") {
                    let o1 = DeserializableObject(from: ["price": 2.0])
                    let anyDouble = 5.0 as Any?
                    
                    o1?.price <-> anyDouble
                    
                    expect(o1?.price) == anyDouble as! Double?
                }
            }
        }
    }
    
}

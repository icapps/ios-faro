import Quick
import Nimble

import Faro
@testable import Faro_Example

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

            }
        }
    }
    
}

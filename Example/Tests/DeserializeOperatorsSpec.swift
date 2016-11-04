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
        guard let json = raw as? [String: Any] else {
            return nil
        }

        self.uuid <-> json["uuid"]
        self.amount <-> json["amount"]
        self.price <-> json["price"]
        self.tapped <-> json["tapped"]
        self.date <-> (json["date"], "yyyyMMdd")
    }

}

class DeserializeOperatorsSpec: QuickSpec {

    override func spec() {
        describe("DeserializeOperatorsSpec") {
            let testAny = ["uuid": "some id", "amount": 20, "price": 5.0, "tapped": true, "date": "1994-08-20"] as Any?
            let json = testAny as! [String: Any]

            context("should give value for") {
                it("should work for relations") {
                    let relationId = ["relation 1", "relation 2"]
                    let animalArray =  [["uuid": relationId[0]], ["uuid": relationId[1]]]
                    let json = ["animalArray": animalArray] as Any?

                    var zoo = Zoo(from: ["":""])

                    zoo <-> json

                    expect(zoo?.animalArray?.count) == 2
                }

                it("should deserialize from object") {
                    let randomNumber = "randomNumber"
                    let json = ["cellNumber": randomNumber, "foodTicket": "ticket"] as Any?

                    var gail = Jail(from: ["":""])

                    gail <-> json

                    expect(gail?.cellNumber) == randomNumber

                }

                it("should deserialize from object Array") {
                    let json = [["uuid": "id1"],["uuid": "id2"]] as Any?
                    var animalArray: [Animal]?

                    animalArray <-> json

                    expect(animalArray?.count) == 2
                }

                it("should deserialize Integers") {
                    let o1 = DeserializableObject(from: ["": ""])

                    o1?.amount <-> json["amount"]

                    expect(o1?.amount) == json["amount"] as! Int?
                }

                it("should deserialize Doubles") {
                    let o1 = DeserializableObject(from: ["":""])

                    o1?.price <-> json["price"]

                    expect(o1?.price) == json["price"] as! Double?
                }

                it("should deserialize Booleans") {
                    let o1 = DeserializableObject(from: ["":""])

                    o1?.tapped <-> json["tapped"]

                    expect(o1?.tapped) == json["tapped"] as! Bool?
                }

                it("should deserialize Strings") {
                    let o1 = DeserializableObject(from: ["":""])

                    o1?.uuid <-> json["uuid"]

                    expect(o1?.uuid) == json["uuid"] as! String?
                }

                it("should deserialize Date") {
                    let o1 = DeserializableObject(from: ["":""])!

                    o1.date <-> (json["date"], "yyyy-MM-dd")

                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let currentDate = formatter.date(from: "1994-08-20")

                    expect(o1.date) == currentDate

                }

                it("should deserialize Date with TimeInterval") {
                    let o1 = DeserializableObject(from: ["":""])!
                    let anyTimeInterval: TimeInterval = 1234.0

                    o1.date <-> anyTimeInterval

                    let date = Date(timeIntervalSince1970: anyTimeInterval)
                    expect(o1.date) == date
                }

                it("should deserialize Date with json and String") {
                    let o1 = DeserializableObject(from: ["":""])!

                    o1.date <-> ("1994-08-20" as Any?, "yyyy-MM-dd")

                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let currentDate = formatter.date(from: "1994-08-20")

                    expect(o1.date) == currentDate
                }
            }
        }
    }

}

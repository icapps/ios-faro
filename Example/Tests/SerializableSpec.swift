import Quick
import Nimble

import Faro
@testable import Faro_Example

extension Zoo: Serializable {

    var json: [String : Any?] {
        get {
            var json = [String: Any]()
            json["uuid"] <-> self.uuid
            json["color"] <-> self.color
            json["animal"] <-> self.animal
            json["animalArray"] <-> self.animalArray
            json["date"] <-> self.date
            return json
        }
    }
}

extension Animal: Serializable {
    var json: [String : Any?] {
        get {
            var json = [String: Any]()
            json["uuid"] <-> self.uuid
            return json
        }
    }
}

class SerializableSpec: QuickSpec {

    override func spec() {
        describe("Serializable") {
            let uuidKey = "uuid"
            context("No animalArray") {
                let json = [uuidKey: "id 1", "color": "something"]
                let zoo = Zoo(from: json)!
                let serializedZoo = zoo.json

                it("should serilize") {
                    expect(serializedZoo[uuidKey] as! String?).to(equal("id 1"))
                    expect(serializedZoo["color"] as! String?).to(equal("something"))
                }
            }

            context("One to one relation - animal") {
                let json = ["animal": ["uuid": "pet"]] as [String : Any?]
                let animal = Zoo(from: json)!
                let animalSerialized = animal.json["animal"] as! [String: Any]

                it("should contain uuid of animal") {
                    expect(animalSerialized["uuid"] as! String?).to(equal("pet"))
                }
            }

            context("One to many relation - animal Array") {
                let animalIDs = ["animal 1", "animal 2"]
                let animalArray =  [[uuidKey: animalIDs[0]], [uuidKey: animalIDs[1]]]
                let animalArrayKey = "animalArray"
                let json = [animalArrayKey: animalArray] as [String: Any]
                let zoo = Zoo(from: json)!

                let serializedzoo = zoo.json
                let serializedAnimalArray = serializedzoo["animalArray"] as! [[String: Any]]
                let animal1 = serializedAnimalArray.first as! [String: Any?]
                let animal2 = serializedAnimalArray.last as! [String: Any?]

                it("should contain the animal ids in the array") {
                    expect(serializedAnimalArray.count).to(equal(2))
                    expect(animal1[uuidKey] as! String?).to(equal(animalIDs[0]))
                    expect(animal2[uuidKey] as! String?).to(equal(animalIDs[1]))
                }

            }
        }
    }
    
}

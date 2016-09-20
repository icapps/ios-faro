import Quick
import Nimble

import Faro
@testable import Faro_Example

extension Zoo: Serializable {
    //implementation handled by extension in Faro. Override if needed.
}

extension Animal: Serializable {
    //implementation handled by extension in Faro. Override if needed.
}

/// MARK: - CustomSerializalble

/// You do not have to implement this. But if you want to serialize relations you have to.
extension Zoo: CustomSerializable {

    func isRelation(for label: String) -> Bool {
        let reations = ["animal": true, "animalArray": true]
        let isRelation = reations[label]
        return isRelation != nil ? isRelation! : false
    }

    func jsonForRelation(with key: String) -> JsonNode {
        if key == "animal" {
            guard let relation = animal?.json else {
                return .nodeNotSerialized
            }
            return .nodeObject(relation)
        } else if key == "animalArray" {
            guard let relations = animalArray else {
                return .nodeNotSerialized
            }

            let jsonRelation = relations.map{ $0.json }
            return .nodeArray(jsonRelation)
        }

        return .nodeNotSerialized
    }
    
}

class SerializableSpec: QuickSpec {

    override func spec() {
        describe("Serializable") {
            let uuidKey = "uuid"
            context("No animalArray") {
                let json = [uuidKey: "id 1", "blue": "something"]
                let zoo = Zoo(from: json)!
                let serializedZoo = zoo.json

                it("should be subscriptable get") {
                    let uuid = zoo[uuidKey] as! String?
                    let blue = zoo["blue"] as! String?

                    expect(uuid).to(equal("id 1"))
                    expect(blue).to(equal("something"))
                }
                it("should serilize") {
                    expect(serializedZoo[uuidKey] as! String?).to(equal("id 1"))
                    expect(serializedZoo["blue"] as! String?).to(equal("something"))
                }
            }

            context("One to one relation - animal") {
                let animalID = "animal 1"
                let animalKey = "animal"

                let json = [animalKey: [uuidKey: animalID]] as [String : Any]
                let zoo = Zoo(from: json)!

                let serializedZoo = zoo.json

                let serializedAnimal = serializedZoo[animalKey] as! [String: Any]

                it("should contain uuid of animal") {
                    expect(serializedAnimal[uuidKey] as! String?).to(equal(animalID))
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

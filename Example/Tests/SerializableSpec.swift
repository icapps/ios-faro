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

                expect(serializedAnimal[uuidKey] as! String?).to(equal(animalID))
            }
        }
    }
    
}

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


        }
    }
    
}

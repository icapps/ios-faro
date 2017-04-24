import Quick
import Nimble

import Faro
@testable import Faro_Example

extension Zoo: Serializable {

    var json: [String : Any] {
		var json = [String: Any]()
		json["uuid"] <| self.uuid
		json["color"] <| self.color
		json["animal"] <| self.animal
		json["animalArray"] <| self.animalArray
		json["date"] <| self.date
		return json
    }
}

extension Animal: Serializable {
    var json: [String : Any] {
		var json = [String: Any]()
		json["uuid"] <| self.uuid
		return json
    }
}

class SerializableSpec: QuickSpec {

    override func spec() {

        describe("should return valid JSON") {

            it("should not throw when some of the json data is nil") {

				expect {
					let zoo = try Zoo(["": ""])
					zoo.uuid = "some id"
					let serializedZoo = zoo.json
					return expect {try JSONSerialization.data(withJSONObject: serializedZoo, options: .prettyPrinted)}.toNot(throwError())
				}.toNot(throwError())

            }
        }
        describe("Serializable") {
            let uuidKey = "uuid"
            context("No animalArray") {

                it("should serilize") {
					expect {
						let json = [uuidKey: "id 1", "color": "something"]
						let zoo = try Zoo(json)
						let serializedZoo = zoo.json

						expect(serializedZoo[uuidKey] as? String).to(equal("id 1"))
						return expect(serializedZoo["color"] as? String).to(equal("something"))
					}.toNot(throwError())
                }
            }

            context("One to one relation - animal") {

                it("should contain uuid of animal") {
					expect {
						let json = ["animal": ["uuid": "pet"]] as [String : Any]
						let animal = try Zoo(json)
						let animalSerialized = animal.json["animal"] as? [String: Any]
						return expect(animalSerialized?["uuid"] as? String).to(equal("pet"))
					}.toNot(throwError())
                }

            }

            context("One to many relation - animal Array") {

                it("should contain the animal ids in the array") {
					expect {
						let animalIDs = ["animal 1", "animal 2"]
						let animalArray =  [[uuidKey: animalIDs[0]], [uuidKey: animalIDs[1]]]
						let animalArrayKey = "animalArray"
						let json = [animalArrayKey: animalArray] as [String: Any]
						let zoo = try Zoo(json)

						let serializedzoo = zoo.json
						let serializedAnimalArray = serializedzoo["animalArray"] as? [[String: Any]]
						let animal1 = serializedAnimalArray?.first
						let animal2 = serializedAnimalArray?.last

						expect(serializedAnimalArray?.count).to(equal(2))
						expect(animal1?[uuidKey] as? String).to(equal(animalIDs[0]))
						return expect(animal2?[uuidKey] as? String).to(equal(animalIDs[1]))
					}.toNot(throwError())

                }

            }
        }
    }

}

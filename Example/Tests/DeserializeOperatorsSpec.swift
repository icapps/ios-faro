import Quick
import Nimble
import Stella

import Faro
@testable import Faro_Example

class DeserializeOperatorsSpec: QuickSpec {

	override func spec() {
		describe("DeserializeOperatorsSpec") {

			context("Create from JSON") {

				context("Relations") {

					it("Single") {
						let randomNumber = "randomNumber"
						let json: [String: Any] = ["cellNumber": randomNumber, "foodTicket": "ticket"]

						expect {
							var jail = try Jail(["cellNumber": "init"])

							try jail |< json

							return expect(jail.cellNumber) == randomNumber
						}.toNot(throwError())

					}

					it("Too many") {
						let json = [["uuid": "id1"], ["uuid": "id2"]] as Any?
						var animalArray = [Animal]()

						try? animalArray |< json

						expect(animalArray.map {$0.uuid}) == ["id1", "id2"]
					}
				}

				context("Primitive Types") {
					var json = [String: Any]()
					var o1: DeserializableObject!

					beforeEach {
						o1 = DeserializableObject()

						json[.uuid] = "some id"
						json[.amount] = 20
						json[.price] = 5.0
						json[.tapped] = true
						json[.date] = "1994-08-20"
					}

					it("Int") {
						o1.amount |< json[.amount]

						expect(o1.amount) == json[.amount] as? Int
					}

					it("Double") {
						o1.price |< json[.price]

						expect(o1?.price) == json[.price] as? Double
					}

					context("Bool") {

						it("Optional") {
							o1?.tapped |< json[.tapped]

							expect(o1?.tapped) == json[.tapped] as? Bool
						}

						it("Required") {

							var requiredBool = true
							try? requiredBool |< false

							expect(requiredBool) == false
						}

					}

					it("String") {
						expect {
							try o1.uuid |< json[.uuid]

							return expect(o1?.uuid) == json[.uuid] as? String
							}.toNot(throwError())
					}

					context("Date") {

						it("String in json") {
							o1.date |< (json[.date], "yyyy-MM-dd")
							try? o1.requiredDate |< (json[.date], "yyyy-MM-dd")

							let formatter = DateFormatter()
							formatter.dateFormat = "yyyy-MM-dd"
							let currentDate = formatter.date(from: "1994-08-20")

							expect(o1.date) == currentDate
							expect(o1.requiredDate) == currentDate

						}

						it("TimeInterval") {

							let anyTimeInterval: TimeInterval = 1234.0

							o1.date |< anyTimeInterval

							let date = Date(timeIntervalSince1970: anyTimeInterval)
							expect(o1.date) == date
						}

						it("String") {
							o1.date |< ("1994-08-20" as Any?, "yyyy-MM-dd")

							let formatter = DateFormatter()
							formatter.dateFormat = "yyyy-MM-dd"
							let currentDate = formatter.date(from: "1994-08-20")

							expect(o1.date) == currentDate
						}
					}
				}

				context("Array of primitive types") {

					it("Int") {
						var numbers: [Int]? = [Int](repeatElement(2, count: 5))
						let jsonArray: Any? =  [Int](repeatElement(6, count: 5))

						numbers |< jsonArray

						expect(numbers) == [Int](repeatElement(6, count: 5))
					}

					it("String") {
						var strings: [String]? = [String](repeatElement("before", count: 5))
						let jsonArray: Any? =  [String](repeatElement("after", count: 5))

						strings |< jsonArray

						expect(strings) == [String](repeatElement("after", count: 5))
					}

					it("Date") {
						var dates: [Date]? = [Date](repeatElement(Date(), count: 5))
						let jsonArray:[(Any?, String)]? =  [(Any?, String)](repeatElement(("1994-08-20" as Any?, "yyyy-MM-dd"), count: 5))

						dates |< jsonArray

						let calendar = NSCalendar.current
						expect(dates?.flatMap {calendar.dateComponents([.year, .month, .day], from: $0).year}) == [1994, 1994, 1994, 1994, 1994]
					}
				}

			}

			context("Update form JSON") {
				var relation = [String: Any]()
				var json = [String: Any]()

				var parent: Parent!

				beforeEach {
					relation[.uuid] = "relation id"
					relation[.amount] = 20
					relation[.tapped] = true
					relation[.date] =  "1994-08-20"
					relation[.price] = 5.0

					json[.uuid] = "route id"
					json[.relation] = relation

					//swiftlint:disable force_try
					parent = try! Parent(json)
				}

				it("updates existing object") {

					expect(parent?.uuid) == "route id"
					expect(parent?.relation.uuid) == "relation id"
					expect(parent?.relation.amount) == 20
					expect(parent?.relation.price) == 5.0
					expect(parent?.relation.tapped) == true
					expect(parent?.relation.date).toNot(beNil())

					let initialRelation = parent?.relation
					try? parent?.update(json)

					expect(parent?.relation) === initialRelation
				}

				context("Too many") {

					var toMany = [[String: Any]]()
					let allUUIDs = ["uuid 1", "uuid 2", "uuid 0"]

					beforeEach {
						toMany.removeAll()
						for i in 0..<3 {
							relation["uuid"] = allUUIDs[i]
							toMany.append(relation)
						}
						json["toMany"] = toMany

						try? parent.update(json)
					}

					it("has toMany relation in JSON") {
						expect(json["toMany"]).toNot(beNil())
					}

					it("has toMany relation in Parent") {
						expect(parent.toMany.map {$0.uuid}) == allUUIDs
					}

					context("Array relation") {

						it("updates") {
							//swiftlint:disable force_cast
							let originalTooMany = parent.toMany

							var relationDifferentPrice = relation
							relationDifferentPrice["uuid"] = parent.toMany[0].uuid
							relationDifferentPrice["price"] = (parent.toMany[0].price ?? 0) + 100

							// remove original price from json
							json["toMany"] = (json["toMany"] as! [[String: Any]]).filter {($0["uuid"] as? String) != parent.toMany[0].uuid}
							// set new price
							var jsonTooManyWithDifferentPrice = json["toMany"] as? [[String: Any]]
							jsonTooManyWithDifferentPrice?.append(relationDifferentPrice)
							json["toMany"] = jsonTooManyWithDifferentPrice

							expect((json["toMany"] as? [[String: Any]])?.map {($0["price"] as? Double) ?? 0}) == [5.0, 5.0, 105.0]

							try? parent.update(json)

							expect(parent.toMany[0]) === originalTooMany[0]
							expect(parent.toMany[1]) === originalTooMany[1]
							expect(parent.toMany[2]) === originalTooMany[2]

							expect(parent.toMany.map {$0.uuid}) == [originalTooMany[0].uuid, originalTooMany[1].uuid, originalTooMany[2].uuid]
							expect(parent.toMany.map {$0.price ?? 0}) == [105.0, 5.0, 5.0]

						}

						context("relation deserialize operator") {

							it("removes id's no longer in JSON") {
								//swiftlint:disable force_cast
								json["toMany"] = (json["toMany"] as! [[String: Any]]).filter {($0["uuid"] as? String) != "uuid 0"}

								try? parent.toMany |< json["toMany"]

								expect(parent.toMany.map {$0.uuid}) == ["uuid 2", "uuid 1"]
							}

							it("add id's in JSON") {
								let uuidAdded = "added id"
								relation["uuid"] = uuidAdded
								toMany.append(relation)
								json["toMany"] = toMany

								let relations = json["toMany"] as? [[String: Any]]

								var expected = allUUIDs
								expected.append(uuidAdded)

								expect(relations?.map {($0["uuid"] as? String) ?? ""}) == expected

								expect(parent.toMany.map {$0.uuid}) == allUUIDs

								try? parent.toMany |< json["toMany"]

								expect(parent.toMany.map {$0.uuid}) == expected
							}

						}
					}

					context("Set relation") {

						var setToMany = [[String: Any]]()
						var setRelation = [String: Any]()

						beforeEach {
							setRelation[.uuid] = "set relation id"
							setRelation[.amount] = 20
							setRelation[.tapped] = true
							setRelation[.date] =  "1994-08-20"
							setRelation[.price] = 5.0

							setToMany.append(setRelation)
							json[.setToMany] = setToMany

							try? parent.update(json)
						}

						it("has set too many") {
							expect(parent.setToMany.map {$0.uuid}) == ["set relation id"]
						}

						it("updates") {
							let originalTooMany = parent.setToMany

							setRelation[.price] = 100.0
							json[.setToMany] = [setRelation]

							expect((json[.setToMany] as? [[String: Any]])?.map {($0[.price] as? Double) ?? 0}) == [100]
							expect((json[.setToMany] as? [[String: Any]])?.map {($0[.uuid] as? String) ?? ""}) == ["set relation id"]

							try? parent.update(json)

							expect(parent.setToMany.first) === originalTooMany.first

							expect(parent.setToMany.map {$0.uuid}) == [originalTooMany.first!.uuid]
							expect(parent.setToMany.map {$0.price ?? 0}) == [100]

						}

						context("relation deserialize operator") {

							it("has element in set") {
								expect(parent.setToMany.map {$0.uuid}) == ["set relation id"]
							}

							it("removes id's no longer in JSON") {

								try? parent.setToMany |< [[String: Any]]()

								expect(parent.setToMany.map {$0.uuid}) == []
							}

							it("add id's in JSON") {
								let uuidAdded = "set added id"
								relation[.uuid] = uuidAdded

								var originalRelation = relation
								originalRelation[.uuid] = "set id 1"

								json[.setToMany] = [relation, originalRelation]

								let relations = json[.setToMany] as? [[String: Any]]

								expect(relations?.map {($0[.uuid] as? String) ?? ""}) == ["set added id", "set id 1"]

								expect(parent.setToMany.map {$0.uuid}) == ["set relation id"]

								try? parent.setToMany |< json[.setToMany]

								expect(parent.setToMany.map {$0.uuid}) == ["set id 1", "set added id" ]
							}

						}
					}

				}
			}
		}
	}

}

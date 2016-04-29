import XCTest
import Nimble
import Quick

@testable import AirRivet


class ResponseControllerSpec: QuickSpec {

	override func spec () {

		describe ("Response controller  ") {
			it("should fail when JSON is invalid") {

				let invalidDict = ["wrong": "json"]
				let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)

				ResponseController().respond(data, succeed: { (response: MockEntity) in
					XCTFail()
					}, fail: { (error) in
						switch error {
						case ResponseError.InvalidDictionary(let anyThing):
							let dictionary = anyThing as! [String: String]
							let key = dictionary["wrong"]
							expect(key).to(equal("json"))
						default:
							XCTFail("Wrong type of error")
						}
				})
			}

			context("Mocking the Mitigator"){
				class MockEntityWithErrorMitigator: GameScore {
					override func environment() -> protocol<Environment, Mockable, Transformable> {
						return Mock()
					}

					override func parseFromDict(json: AnyObject) throws {
						if let _ = json["wrong"] {
							throw ResponseError.InvalidDictionary(dictionary: json as! [String : AnyObject])
						}else {
							try super.parseFromDict(json)
						}
					}

					override func responseMitigator() -> ResponseMitigatable {
						return MockMitigator()
					}
				}

				class MockMitigator: DefaultMitigator {
					override func invalidDictionary(dictionary: AnyObject) throws -> AnyObject?{
						return dictionary["writeNode"]
					}
				}

				it("should succeed with invalid json if the mitigator handles the error") {

					let expectedObjectId = "expectedObjectId"
					let invalidDict = ["wrong": "json", "writeNode": ["objectId":expectedObjectId]]
					let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)


					ResponseController().respond(data, succeed: { (response: MockEntityWithErrorMitigator) in
						expect(response.objectId).to(equal(expectedObjectId))
						}, fail: { (error) in
							XCTFail("Should not raise \(error)")
					})
				}
                
                it("Should succeed with invalid json if the mitigator handles the error with an array"){
                    let expectedObjectId = "expectedObjectId"
                    let expectedObjectId2 = "expectedObjectId2"
                    let invalidDict = ["wrong": "json", "writeNode": [["objectId":expectedObjectId], ["objectId":expectedObjectId2]]]
                    let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)
                    
                    ResponseController().respond(data, succeed: { (result: [MockEntityWithErrorMitigator]) in
                        expect(result[0].objectId).to(equal(expectedObjectId))
                        expect(result[1].objectId).to(equal(expectedObjectId2))
                        expect(result.count).to(equal(2))
                        }, fail: { (error) in
                            print("Error occured \(error)")
                    })
                }
			}
		}
	}

}

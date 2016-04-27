import XCTest
import Nimble
import Quick

@testable import AirRivet


class ResponseControllerSpec: QuickSpec {

	override func spec () {

		describe ("Response controller  ") {
//			it("should fail when JSON is invalid") {
//
//				let invalidDict = ["wrong": "json"]
//				let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)
//
//				ResponseController().respond(data, succeed: { (response: MockEntity) in
//					XCTFail()
//					}, fail: { (error) in
//						switch error {
//						case ResponseError.InvalidDictionary(let anyThing):
//							let dictionary = anyThing as! [String: String]
//							let key = dictionary["wrong"]
//							expect(key).to(equal("json"))
//						default:
//							XCTFail("Wrong type of error")
//						}
//				})
//			}

			context("Mocking the Mitigator"){
				class MockEntityWithErrorMitigator: GameScore {
					override func environment() -> protocol<Environment, Mockable, Transformable> {
						return Mock()
					}

					override func parseFromDict(json: AnyObject) throws {
						print(json)
						throw ResponseError.InvalidDictionary(dictionary: json as! [String : AnyObject])
					}

					override func responseMitigator() -> ResponsMitigatable {
						return MockMitigator()
					}
				}

				class MockMitigator: DefaultMitigator {
					override func responseInvalidDictionary(dictionary: AnyObject) throws{
						//TODO: I need the object here
						//mock the throwing out
						return
					}
				}

				it("should succeed with invalid json if the mitigator handles the error") {

					let expectedObjectId = "expectedObjectId"
					let invalidDict = ["wrong": "json", "writeNode": ["objectId":expectedObjectId]]
					let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)

					var result = MockEntityWithErrorMitigator()

					ResponseController().respond(data, succeed: { (response: MockEntityWithErrorMitigator) in
						result = response
						}, fail: { (error) in
							XCTFail("Should not raise \(error)")
					})

					expect(result.objectId).to(equal(expectedObjectId))
				}
			}
		}
	}

}

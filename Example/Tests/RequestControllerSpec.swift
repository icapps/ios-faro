//
//  RequestControllerSpec.swift
//  AirRivet
//
//  Created by Stijn Willems on 25/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Quick
import Nimble

@testable import AirRivet

class MockEntity: GameScore {

	override func contextPath() -> String {
		return "non existing"
	}

	override func environment() -> protocol<Environment, Mockable, Transformable> {
		return Mock ()
	}

	override func parseFromDict(json: AnyObject) throws {
		guard let
			dict = json as? [String: AnyObject],
			_ = dict["playername"] else  {

		throw ResponseError.InvalidDictionary(dictionary: json as! [String : AnyObject])

		}

	}
}


class RequestControllerSpec: QuickSpec {

	override func spec() {
		describe("Error cases") {

			let requestController = RequestController<MockEntity>()

			let failingCompletion = { (response: [MockEntity]) in
				XCTFail() // we should not complete
			}
			let successFailure = { (error: ResponseError) in
				//Success no assert
			}

			it("should fail when contextPaht does not exist") {
				expect { try requestController.retrieve(failingCompletion, failure: successFailure) }.to(throwError(closure: { (error) in
					expect(error).to(matchError(ResponseError.InvalidResponseData))
				}))
			}

			it("should fail when JSON is invalid") {

				let invalidDict = ["wrong": "json"]
				let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)

				requestController.success(data, completion: failingCompletion, failure: { (error) in

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

			context("Mocking the ErrorController"){
				class MockEntityWithErrorController: GameScore {
					override func environment() -> protocol<Environment, Mockable, Transformable> {
						return Mock()
					}

					override func parseFromDict(json: AnyObject) throws {
						throw ResponseError.InvalidDictionary(dictionary: json as! [String : AnyObject])
					}

					override func responseErrorController() -> ErrorController {
						return MockErrorController()
					}
				}

				class MockErrorController: ConcreteErrorController {
					override func responseInvalidDictionary(dictionary: AnyObject) throws{
						//mock the throwing out
						return
					}
				}
				
				it("should succeed with invalid json if the error controller handles the error") {

					let invalidDict = ["wrong": "json"]
					let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)

					let request2 = RequestController<MockEntityWithErrorController>()

					request2.success(data, completion: { (response: MockEntityWithErrorController) in
						//
						}, failure: { (error) in
							XCTFail("Should not raise \(error)")
					})

					
				}
			}
		}
	}


}

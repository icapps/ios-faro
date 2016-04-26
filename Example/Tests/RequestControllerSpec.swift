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
			let failingCompletion = { (response: [MockEntity]) in
				XCTFail() // we should not complete
			}
			let successFailure = { (error: ResponseError) in
				//Success no assert
			}

			it("should fail when contextPaht does not exist") {
				expect { try RequestController().retrieve(failingCompletion, failure: successFailure) }.to(throwError(closure: { (error) in
					expect(error).to(matchError(ResponseError.InvalidResponseData))
				}))
			}

			it("should fail when JSON is invalid") {

				let invalidDict = ["wrong": "json"]
				let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)

				RequestController().succeed(data, completion: failingCompletion, failure: { (error) in

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
						throw ResponseError.InvalidDictionary(dictionary: json as! [String : AnyObject])
					}

					override func responseMitigator() -> ResponsMitigatable {
						return MockMitigator()
					}
				}

				class MockMitigator: DefaultMitigator {
					override func responseInvalidDictionary(dictionary: AnyObject) throws{
						//mock the throwing out
						return
					}
				}
				
				it("should succeed with invalid json if the error controller handles the error") {

					let invalidDict = ["wrong": "json"]
					let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)

					RequestController().succeed(data, completion: { (response: MockEntityWithErrorMitigator) in
						//TODO:
						}, failure: { (error) in
							XCTFail("Should not raise \(error)")
					})

					//TODO: See if you can parse from invalid data to the objects you want. 
					//1. An error happens
					//2. Errors in the dictionary are removed
					//3. The parsing is continued
					//4. The correct objects are returned.
					
				}
			}
		}
	}


}

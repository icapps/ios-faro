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
			throw ResponseError.InvalidResponseData
		}

		try super.parseFromDict(json)
	}
}

class RequestControllerSpec: QuickSpec {
	override func spec() {
		describe("Error cases") {



			let requestController = RequestController<MockEntity>()

			let failingCompletion = { (response: [MockEntity]) in
				XCTFail() // we should not complete
			}
			let successFailure = { (error: RequestError) in
				//Success no assert
			}

			it("should fail when contextPaht does not exist") {
				expect { try requestController.retrieve(failingCompletion, failure: successFailure) }.to(throwError(closure: { (error) in
					expect(error).to(matchError(ResponseError.InvalidResponseData))
				}))
			}

			it("should fail when JSON is invalid") {

				let data = try! NSJSONSerialization.dataWithJSONObject(["wrong": "json"], options: .PrettyPrinted)

				requestController.success(data, completion: failingCompletion, failure: { (error) in
					expect(error).to(matchError(ResponseError.InvalidResponseData))
				})

			}
		}
	}


}

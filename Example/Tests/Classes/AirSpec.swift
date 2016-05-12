//
//  Airspec.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Quick
import Nimble

@testable import AirRivet

// MARK: - Mocks

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

// MARK: - Specs

class AirSpec: QuickSpec {

	override func spec() {
		describe("Throwing errors in request construction") {

			it("should fail when contextPaht does not exist") {
				expect {
					try Air.retrieve(succeed: { (response: [MockEntity]) in
						XCTFail()
					})
				}.to(throwError { (error) in
					switch error {
						case ResponseError.InvalidResponseData(_):
							break
						default:
							XCTFail("Should not throw \(error)")
					}
				})
			}
            
		}
	}

}
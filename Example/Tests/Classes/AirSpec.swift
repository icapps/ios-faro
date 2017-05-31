//
//  Airspec.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Quick
import Nimble

import AirRivet

@testable import AirRivet_Example

// MARK: - Specs

class AirSpec: QuickSpec {

	override func spec() {
		describe("Throwing errors in request construction") {

			it("should fail when contextPaht does not exist") {
				expect {
					try Air.fetch(succeed: { (response: [MockEntity]) in
						XCTFail()
					})
				}.to(throwError { (error) in
					switch error {
						case ResponseError.invalidResponseData(_):
							break
						default:
							XCTFail("Should not throw \(error)")
					}
				})
			}
            
		}
	}

}

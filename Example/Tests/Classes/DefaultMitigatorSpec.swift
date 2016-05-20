//
//  DefaultMitigatorSpec.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Nimble
import Quick
import XCTest

@testable import AirRivet

// MARK: - Specs

class DefaultMitigatorSpec: QuickSpec {

	override func spec () {
		describe("Throwing behaviour on mitigation") {
            
			let mitigator = MitigatorNoPrinting()

			it("should rethrow request errors") {
				expect {
                    try mitigator.mitigate {
                        throw RequestError.InvalidBody
                    }
                }.to(throwError(closure: { (error) in
					expect(error).to(matchError(RequestError.InvalidBody))
				}))

				expect {
                    try mitigator.mitigate {
                        throw RequestError.General
                    }
                }.to(throwError(closure: { (error) in
					expect(error).to(matchError(RequestError.General))
				}))
			}

			context("response errors") {
                
                it("should throw invalid response data error") {
                    expect {
                        try mitigator.mitigate {
                            throw ResponseError.InvalidResponseData(data: nil)
                        }
                    }.to(throwError(closure: { (error) in
                        switch error {
                        case ResponseError.InvalidResponseData(_):
                            break
                        default:
                            XCTFail("Should not throw \(error)")
                        }
                    }))
                }
                
                it("should throw invalid dictionary error") {
                    expect {
                        try mitigator.mitigate {
                            throw ResponseError.InvalidDictionary(dictionary: ["bla": "bla"])
                        }
                    }.to(throwError(closure: { (error) in
                        switch error {
                        case ResponseError.InvalidDictionary(dictionary: _):
                            break
                        default:
                            XCTFail("Should not throw \(error)")
                        }
                    }))
                }
                
                it("should throw invalid response error") {
                    expect {
                        try mitigator.mitigate {
                            throw ResponseError.ResponseError(error: nil)
                        }
                    }.to(throwError(closure: { (error) in
                        switch error {
                        case ResponseError.ResponseError(error: _):
                            break
                        default:
                            XCTFail("Should not throw \(error)")
                        }
                    }))
                }
                
			}

			it("should throw any other errror", closure: {
				enum RandomError: ErrorType {
					case Random
				}
				expect {
                    try mitigator.mitigate {
                        throw RandomError.Random
                    }
                }.to(throwError())
			})
		}
	}
}

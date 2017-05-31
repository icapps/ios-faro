//
//  MitigatorDefaultSpec.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Nimble
import Quick
import XCTest

import AirRivet
@testable import AirRivet_Example


// MARK: - Specs

class MitigatorDefaultSpec: QuickSpec {

	override func spec () {
		describe("Throwing behaviour on mitigation") {
            
			let mitigator = MitigatorNoPrinting()

			it("should rethrow request errors") {
				expect {
                    try mitigator.mitigate {
                        throw RequestError.invalidBody
                    }
                }.to(throwError(closure: { (error) in
					expect(error).to(matchError(RequestError.invalidBody))
				}))

				expect {
                    try mitigator.mitigate {
                        throw RequestError.general
                    }
                }.to(throwError(closure: { (error) in
					expect(error).to(matchError(RequestError.general))
				}))
			}

			context("response errors") {

                it("should throw invalid response data error") {
                    expect {
                        try mitigator.mitigate {
                            throw ResponseError.invalidResponseData(data: nil)
                        }
                    }.to(throwError(closure: { (error) in
                        switch error {
                        case ResponseError.invalidResponseData(_):
                            break
                        default:
                            XCTFail("Should not throw \(error)")
                        }
                    }))
                }
                
                it("should throw invalid dictionary error") {
                    expect {
                        try mitigator.mitigate {
                            throw ResponseError.invalidDictionary(dictionary: ["bla": "bla"])
                        }
                    }.to(throwError(closure: { (error) in
                        switch error {
                        case ResponseError.invalidDictionary(dictionary: _):
                            break
                        default:
                            XCTFail("Should not throw \(error)")
                        }
                    }))
                }
                
                it("should throw invalid response error") {
                    expect {
                        try mitigator.mitigate {
                            throw ResponseError.responseError(error: nil)
                        }
                    }.to(throwError(closure: { (error) in
                        switch error {
                        case ResponseError.responseError(error: _):
                            break
                        default:
                            XCTFail("Should not throw \(error)")
                        }
                    }))
                }

				it("should throw general error with code and json") {
					expect {
						try mitigator.mitigate {
							throw ResponseError.generalWithResponseJSON(statuscode: 0, responseJSON: ["":""])
						}
						}.to(throwError(closure: { (error) in
							switch error {
							case ResponseError.generalWithResponseJSON(statuscode: _ , responseJSON: _):
								break
							default:
								XCTFail("Did throw wrong error \(error)")
							}
						}))
				}

				it("should throw invalid response error") {
					expect {
						try mitigator.mitigate {
							throw ResponseError.general(statuscode: 0)
						}
						}.to(throwError(closure: { (error) in
							switch error {
							case ResponseError.general(statuscode: _):
								break
							default:
								XCTFail("Should not throw \(error)")
							}
						}))
				}

			}

			context("mapError", {
				it("should throw EnityShouldBeUniqueForJSON") {
					expect {
						try mitigator.mitigate {
							throw MapError.enityShouldBeUniqueForJSON(json: ["":""], typeName: "Type")
						}
						}.to(throwError(closure: { (error) in
							switch error {
							case MapError.enityShouldBeUniqueForJSON(json: _ , typeName: _):
								break
							default:
								XCTFail("Should not throw \(error)")
							}
						}))
				}

				it("should throw invalid response data error") {
					expect {
						try mitigator.mitigate {
							throw MapError.jsonHasNoUniqueValue(json: ["":""])
						}
						}.to(throwError(closure: { (error) in
							switch error {
							case MapError.jsonHasNoUniqueValue(json: _):
								break
							default:
								XCTFail("Should not throw \(error)")
							}
						}))
				}
			})

			it("should throw any other errror", closure: {
				enum RandomError: Error {
					case random
				}
				expect {
                    try mitigator.mitigate {
                        throw RandomError.random
                    }
                }.to(throwError())
			})
		}
	}
}

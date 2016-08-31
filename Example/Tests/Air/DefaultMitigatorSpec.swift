import Nimble
import Quick
import XCTest

import Faro
@testable import Faro_Example


// MARK: - Specs

class MitigatorDefaultSpec: QuickSpec {

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

				it("should throw general error with code and json") {
					expect {
						try mitigator.mitigate {
							throw ResponseError.GeneralWithResponseJSON(statuscode: 0, responseJSON: ["":""])
						}
						}.to(throwError(closure: { (error) in
							switch error {
							case ResponseError.GeneralWithResponseJSON(statuscode: _ , responseJSON: _):
								break
							default:
								XCTFail("Did throw wrong error \(error)")
							}
						}))
				}

				it("should throw invalid response error") {
					expect {
						try mitigator.mitigate {
							throw ResponseError.General(statuscode: 0)
						}
						}.to(throwError(closure: { (error) in
							switch error {
							case ResponseError.General(statuscode: _):
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
							throw MapError.EnityShouldBeUniqueForJSON(json: ["":""], typeName: "Type")
						}
						}.to(throwError(closure: { (error) in
							switch error {
							case MapError.EnityShouldBeUniqueForJSON(json: _ , typeName: _):
								break
							default:
								XCTFail("Should not throw \(error)")
							}
						}))
				}

				it("should throw invalid response data error") {
					expect {
						try mitigator.mitigate {
							throw MapError.JSONHasNoUniqueValue(json: ["":""])
						}
						}.to(throwError(closure: { (error) in
							switch error {
							case MapError.JSONHasNoUniqueValue(json: _):
								break
							default:
								XCTFail("Should not throw \(error)")
							}
						}))
				}
			})

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

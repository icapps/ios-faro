import Nimble
import Quick
import XCTest
@testable import AirRivet

class DefaultMitigatorSpec: QuickSpec {

	override func spec () {
		describe("Throwing behaviour on mitigation") {
			let mitigator = DefaultMitigator()

			it("should rethrow for request errors") {

				expect { try mitigator.mitigate {throw RequestError.InvalidBody} }.to(throwError(closure: { (error) in
					expect(error).to(matchError(RequestError.InvalidBody))
				}))

				expect { try mitigator.mitigate {throw RequestError.General} }.to(throwError(closure: { (error) in
					expect(error).to(matchError(RequestError.General))
				}))
			}

			it("should throw for response errors") {
			
				expect { try mitigator.mitigate {throw ResponseError.InvalidResponseData(data: nil)} }.to(throwError(closure: { (error) in
					switch error {
					case ResponseError.InvalidResponseData(_):
							break
					default:
						XCTFail("Should not throw \(error)")
					}
				}))

				expect { try mitigator.mitigate {throw ResponseError.InvalidDictionary(dictionary: ["bla": "bla"]) } }.to(throwError(closure: { (error) in
					switch error {
					case ResponseError.InvalidDictionary(dictionary: _):
						break
					default:
						XCTFail("Should not throw \(error)")
					}
				}))

				expect { try mitigator.mitigate {throw ResponseError.ResponseError(error: nil) } }.to(throwError(closure: { (error) in
					switch error {
					case ResponseError.ResponseError(error: _):
						break
					default:
						XCTFail("Should not throw \(error)")
					}
				}))

			}
		}
	}
}

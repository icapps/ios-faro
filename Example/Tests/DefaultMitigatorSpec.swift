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
			
				expect { try mitigator.mitigate {throw ResponseError.InvalidResponseData} }.to(throwError(closure: { (error) in
					expect(error).to(matchError(ResponseError.InvalidResponseData))
				}))

			}
		}
	}
}

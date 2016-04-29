import Nimble
import Quick
import XCTest
@testable import AirRivet

class DefaultMitigatorSpec: QuickSpec {

	override func spec () {
		describe("ErrorMitigator default behaviour") {
			let errorController = DefaultMitigator()

			it("should throw Request Errors for mistakes in the request") {
				expect { try errorController.requestBodyError() }.to(throwError(closure: { (error) in
					expect(error).to(matchError(RequestError.InvalidBody))
				}))

				expect { try errorController.requestAuthenticationError() }.to(throwError(closure: { (error) in
					expect(error).to(matchError(ResponseError.InvalidAuthentication))
				}))
				expect { try errorController.requestGeneralError()}.to(throwError(closure: { (error) in
					expect(error).to(matchError(RequestError.General))
				}))
			}

			it("should throw Response Errors when the response cannot be interpreted") {
				expect { try errorController.responseDataEmptyError() }.to(throwError(closure: { (error) in
					expect(error).to(matchError(ResponseError.InvalidResponseData))
				}))

				//TODO this test needs to be finished when RequestController is refactored
//				expect { try errorController.responseDataEmptyError() }.to(throwError(closure: { (error) in
//					_ = NSError(domain: "101", code: 101, userInfo: nil)
////					let responseError = ResponseError.ResponseError(error: expectedNsError)
////					expect(error).to(matchError()
//				}))
			}
		}
	}
//
//    func testRequestResponseError() {
//        let expectedError = NSError(domain: "com.icapps.test", code: 123, userInfo: [NSLocalizedDescriptionKey:"some error"])
//        XCTAssertThrowsError(try errorController.requestResponseError(expectedError), "method should trow correct error") { error in
//            guard let thrownError = error as? RequestError else {
//                XCTFail("wrong error type")
//                return
//            }
//            switch thrownError {
//            case .ResponseError(let responseError):
//                XCTAssertEqual(responseError, expectedError)
//            default:
//                XCTFail("wrong error type")
//            }
//        }
//    }
}

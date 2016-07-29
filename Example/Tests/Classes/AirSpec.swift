
//

import Quick
import Nimble

import Faro
@testable import Faro_Example

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
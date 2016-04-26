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

		throw ResponseError.InvalidDictionary(dictionary: json as! [String : AnyObject])

		}
	}
}


class AirSpec: QuickSpec {

	override func spec() {
		describe("Throwing errors in request construction") {

			it("should fail when contextPaht does not exist") {
				expect {
					try Air.retrieve(succeed: { (response: [MockEntity]) in
						XCTFail() // we should not complete
					})
				}.to(throwError { (error) in
					expect(error).to(matchError(ResponseError.InvalidResponseData))
				})
			}
		}
	}


}

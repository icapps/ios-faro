// https://github.com/Quick/Quick

import Quick
import Nimble
import AirRivet
import Foundation

class Mock: Environment {
	var serverUrl = ""
	var request = NSMutableURLRequest()

	func shouldMock() -> Bool {
		return true
	}
}

class MockGameScore: GameScore {

	override func contextPath() -> String {
		return "gameScoreArray"
	}

	override func environment() -> Environment {
		return Mock ()
	}
}

class GameScoreSpec: QuickSpec {
    override func spec() {
        describe("GameScore") {

			let test = RequestController<MockGameScore>()


			it ("Should be synchronous because we implement the Mockable protocol") {
				var result = [MockGameScore]()
				try! test.retrieve({ (response) in
					result = response
				})
				expect(result).to(haveCount(5))
			}

//            it("save succeeds") {
//
//				var success = false
//				try! test.save(gameScore, completion: { (response) in
//					success = true
//					})
//				expect(success).toEventually(equal(true))
//            }
//
//			it("retreive array of gamescores", closure: {
//				var result = [GameScore]()
//				try! test.retrieve({ (response) in
//					result = response
//				})
//				expect(result).toEventually(haveCount(100))
//			})
//
//			it("retreive object with a specific id", closure: { 
//				var result = gameScore
//				let objectId = "ta40DRgRAn"
//				try! test.retrieve(objectId, completion: { (response) in
//					result = response
//				})
//
//				expect(result.score).toEventually(equal(1337))
//				expect(result.playerName).toNot(beNil())
//			})
        }
    }
}

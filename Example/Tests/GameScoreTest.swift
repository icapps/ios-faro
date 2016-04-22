// https://github.com/Quick/Quick

import Quick
import Nimble
import AirRivet
import Foundation

class Mock: Environment, Mockable, Transformable {
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

	override func environment() -> protocol<Environment, Mockable, Transformable> {
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

			it("all gamescores should be parsed", closure: {
				var result = [MockGameScore]()
				let expected = ["Bob", "Daniel", "Hans", "Stijn", "Jelle"]
				try! test.retrieve({ (response) in
					result = response

				})
				for i in 0..<result.count {
					let gameScore = result[i]
					expect(gameScore.playerName).to(equal(expected[i]))
				}
			})
            it("save succeeds by mocking") {

				var success = false
				let gameScore = MockGameScore()
				gameScore.score = 1
				gameScore.cheatMode = false
				gameScore.playerName = "Foo"
				
				try! test.save(gameScore, completion: { (response) in
					success = true
					})
				expect(success).to(equal(true))
            }

			it("retrieve a single gamescore by objectID"){

				var result = MockGameScore()
				let objectId = "1275"
				try! test.retrieve(objectId, completion: { (response) in
					result = response
				})
				expect(result.objectId).to(equal(objectId))
			}

        }
    }
}

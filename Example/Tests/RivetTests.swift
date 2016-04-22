// https://github.com/Quick/Quick

import Quick
import Nimble
import AirRivet

//TODO: Make this run with a dummy service
class RivetSpec: QuickSpec {
    override func spec() {
        describe("GameScore") {

			let test = RequestController<GameScore>()
			let gameScore = GameScore(json: [
				"score": 1000,
				"cheatMode": false,
				"playerName": "Sean Plott"
				])

            it("save succeeds") {

				var success = false
				try! test.save(gameScore, completion: { (response) in
					success = true
					})
				expect(success).toEventually(equal(true))
            }

			it("retreive array of gamescores", closure: {
				var result = [GameScore]()
				try! test.retrieve({ (response) in
					result = response
				})
				expect(result).toEventually(haveCount(100))
			})

			it("retreive object with a specific id", closure: { 
				var result = gameScore
				let objectId = "ta40DRgRAn"
				try! test.retrieve(objectId, completion: { (response) in
					result = response
				})

				expect(result.score).toEventually(equal(1337))
				expect(result.playerName).toNot(beNil())
			})
        }
    }
}

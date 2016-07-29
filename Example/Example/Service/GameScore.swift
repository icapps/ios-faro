import Faro
import CoreData
/**
In this example GameScore has to inherit from NSObject to be usable in Objective-C. In a pure Swift project this is not needed.
*/
class GameScore: FaroParent, EnvironmentConfigurable {

	var score: Int?
	var cheatMode: Bool?
	var playerName: String?

	//MARK: - Parsable override
	override func toDictionary()-> NSDictionary? {
		return [
			"score": score!,
			"cheatMode": cheatMode!,
			"playerName": playerName!
		]
	}

	override func map(json: AnyObject) throws {
		if let json = json as? [String: AnyObject] {
			if let uniqueValue = json["objectId"] as? String {
				self.uniqueValue = uniqueValue
			}
			if let score = json["score"] as? Int {
				self.score = score
			}
			if let cheatMode = json["cheatMode"] as? Bool {
				self.cheatMode = cheatMode
			}

			if let playerName = json["playerName"] as? String {
				self.playerName = playerName
			}
		}else {
			throw ResponseError.InvalidDictionary(dictionary: json)
		}
	}

	//MARK: - Transformable override
	override class func rootKey() -> String? {
		return "results"
	}
	// MARK: - EnvironmentConfigurable
    
	class func contextPath() -> String {
		return "GameScore"
	}

	class func environment()-> protocol<Environment, Mockable> {
		return EnvironmentParse<GameScore>()
	}
}
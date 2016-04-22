import AirRivet

/**
Model object that implements protocol `BaseModel` that can be fount in pod `AirRivet`.

In this example GameScore has to inherit from NSObject to be usable in Objective-C. In a pure Swift project this is not needed.
*/
public class GameScore: NSObject, UniqueAble, EnvironmentConfigurable,  ErrorControlable, Parsable {

	public var score: Int?
	public var cheatMode: Bool?
	public var playerName: String?

	public var objectId: String?
	public var errorController: ErrorController

	public required init(json: AnyObject) {
		errorController = ConcreteErrorController()
		super.init()
		importFromJSON(json)
	}

	public static func getErrorController() -> ErrorController {
		return ConcreteErrorController()
	}

	//MARK: BaseModel Protocol Type
	public static func contextPath() -> String {
		return "GameScore"
	}

	public static func environment()-> Environment {
		return ParseExampleService<GameScore>()
	}

	//MARK: BaseModel Protocol Instance
	public func body()-> NSDictionary? {
		return [
			"score": score!,
			"cheatMode": cheatMode!,
			"playerName": playerName!
		]
	}

	public func importFromJSON(json: AnyObject) {
		if let json = json as? NSDictionary {
			if let objectId = json["objectId"] as? String {
				self.objectId = objectId
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
		}
	}
}
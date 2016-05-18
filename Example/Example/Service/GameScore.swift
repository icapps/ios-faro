//
//  GameScore.swift
//  AirRivet
//
//  Created by Stijn Willems on 04/01/2016.
//  2016 iCapps. MIT Licensed.
//

import AirRivet

/**
Model object that implements protocol `BaseModel` that can be fount in pod `AirRivet`.

In this example GameScore has to inherit from NSObject to be usable in Objective-C. In a pure Swift project this is not needed.
*/
public class GameScore: NSObject, UniqueAble,  Mitigatable, Parsable, EnvironmentConfigurable {

    // MARK: - Game variables
    
	public var score: Int?
	public var cheatMode: Bool?
	public var playerName: String?
    
    // MARK: - UniqueAble

	public var objectId: String?
    
    // MARK: - Init

	public required override init() {
		super.init()
	}
    
    // MARK: - Parsable

	public func toDictionary()-> NSDictionary? {
		return [
			"score": score!,
			"cheatMode": cheatMode!,
			"playerName": playerName!
		]
	}

	public func parseFromDict(json: AnyObject) throws {
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

	// MARK: - Mitigatable
	
	public class func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return DefaultMitigator()
	}

	public class func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return DefaultMitigator()
	}

	// MARK: - EnvironmentConfigurable
    
	public class func contextPath() -> String {
		return "GameScore"
	}

	public class func environment()-> protocol<Environment, Mockable, Transformable> {
		return Parse<GameScore>()
	}

	public class func rootKey() -> String? {
		return "results"
	}
}
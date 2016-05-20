//
//  GameScore.swift
//  AirRivet
//
//  Created by Stijn Willems on 04/01/2016.
//  2016 iCapps. MIT Licensed.
//

import AirRivet
import CoreData
/**
Model object that implements protocol `BaseModel` that can be fount in pod `AirRivet`.

In this example GameScore has to inherit from NSObject to be usable in Objective-C. In a pure Swift project this is not needed.
*/
class GameScore: NSObject, Rivetable {

    // MARK: - Game variables
    
	var score: Int?
	var cheatMode: Bool?
	 var playerName: String?
    
    // MARK: - UniqueAble

	var objectId: String?
    
    // MARK: - Init

	required init(json: AnyObject, managedObjectContext: NSManagedObjectContext? = GameScore.managedObjectContext()) throws {
		super.init()
		try self.map(json)
	}
    
    // MARK: - Parsable

	func toDictionary()-> NSDictionary? {
		return [
			"score": score!,
			"cheatMode": cheatMode!,
			"playerName": playerName!
		]
	}

	func map(json: AnyObject) throws {
		if let json = json as? [String: AnyObject] {
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
		}else {
			throw ResponseError.InvalidDictionary(dictionary: json)
		}
	}

	class func managedObjectContext() -> NSManagedObjectContext? {
		return nil
	}

	static func lookupExistingObjectFromJSON(json: AnyObject, managedObjectContext: NSManagedObjectContext?) -> Self? {
		return nil
	}

	// MARK: - Mitigatable
	
	class func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return DefaultMitigator()
	}

	class func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return DefaultMitigator()
	}

	// MARK: - EnvironmentConfigurable
    
	class func contextPath() -> String {
		return "GameScore"
	}

	class func environment()-> protocol<Environment, Mockable> {
		return EnvironmentParse<GameScore>()
	}

	class func rootKey() -> String? {
		return "results"
	}

	//MARK: - Transfromable
	class func transform() -> TransformJSON {
		return TransformJSON()
	}
}
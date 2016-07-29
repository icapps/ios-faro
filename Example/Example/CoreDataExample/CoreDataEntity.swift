import Foundation
import CoreData

import Faro

class CoreDataEntity: FaroCoreDataParent, EnvironmentConfigurable, CoreDataParsable, CoreDataEntityDescription {


	//MARK: - CoreDataEntityDescription

	class func entityName() -> String {
		return typeName(CoreDataEntity)
	}

	class func uniqueValueKey() -> String {
		return "uniqueValue"
	}

	//MARK: - CoreDataParsable

	/**
	You should override this method. Swift does not inherit the initializers from its superclass.
	*/
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}

	required init(json: AnyObject, managedObjectContext: NSManagedObjectContext? = CoreDataEntity.managedObjectContext()) throws {
		let entity = NSEntityDescription.entityForName(CoreDataEntity.entityName(), inManagedObjectContext: managedObjectContext!)
		super.init(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
		try self.map(json)
	}

	func toDictionary()-> NSDictionary? {
		return ["uniqueValue": uniqueValue!, "username": username!]
	}

	func map(json: AnyObject) throws {
		if let uniqueValue = json["uniqueValue"] as? String {
			self.uniqueValue = uniqueValue
		}

		if let username = json["username"] as? String {
			self.username = username
		}
	}

	static func lookupExistingObjectFromJSON(json: AnyObject, managedObjectContext: NSManagedObjectContext?) throws -> Self? {

		guard let managedObjectContext = managedObjectContext else  {
			return nil
		}

		return autocast(try fetchInCoreDataFromJSON(json, managedObjectContext: managedObjectContext, entityName: CoreDataEntity.entityName(), uniqueValueKey: CoreDataEntity.uniqueValueKey()))
	}

	//MARK: - Transformable override
	override class func rootKey() -> String? {
		return "results"
	}

	//MARK: - EnvironmentConfigurable

	class func environment() -> protocol<Environment, Mockable> {
		return EnvironmentParse<CoreDataEntity>()
	}

	static func contextPath() -> String {
		return CoreDataEntity.entityName()
	}

}


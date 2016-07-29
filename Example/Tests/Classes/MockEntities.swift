import Foundation
import Faro
@testable import Faro_Example

/**
Example of a mock without CoreData
*/

class MockEntity: GameScore {

	override class func contextPath() -> String {
		return "non existing"
	}

	override class func environment() -> protocol<Environment, Mockable> {
		return Mock ()
	}

	override func map(json: AnyObject) throws {
		guard let
			dict = json as? [String: AnyObject],
			_ = dict["playername"] else  {
				throw ResponseError.InvalidDictionary(dictionary: json as! [String : AnyObject])
		}
	}

	class override func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return MitigatorNoPrinting()
	}

	class override func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return MitigatorNoPrinting()
	}
}

/**
CoreData entity mock. You should provide a managedObjectContext in your Spec
*/

class MockCoreDataEntity: CoreDataEntity {

	override class func environment() -> protocol<Environment, Mockable> {
		return Mock()
	}

	class override func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return MitigatorNoPrinting()
	}

	class override func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return MitigatorNoPrinting()
	}

	/**
	Transform should be overridden because TransFormCoreData is async.
	*/
	class override func transform() -> TransformJSON {
		return TransformJSON()
	}


}
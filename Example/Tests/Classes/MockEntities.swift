//
//  MockEntities.swift
//  AirRivet
//
//  Created by Stijn Willems on 03/06/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import AirRivet
@testable import AirRivet_Example

/**
Example of a mock without CoreData
*/

class MockEntity: GameScore {

	override class func contextPath() -> String {
		return "non existing"
	}

	override class func environment() -> Environment & Mockable {
		return Mock ()
	}

	override func map(_ json: Any) throws {
		guard let
			dict = json as? [String: Any],
			let _ = dict["playername"] else  {
				throw ResponseError.InvalidDictionary(dictionary: json as! [String : Any])
		}
	}

	class override func responseMitigator() -> ResponseMitigatable & Mitigator {
		return MitigatorNoPrinting()
	}

	class override func requestMitigator() -> RequestMitigatable & Mitigator {
		return MitigatorNoPrinting()
	}
}

/**
CoreData entity mock. You should provide a managedObjectContext in your Spec
*/

class MockCoreDataEntity: CoreDataEntity {

	override class func environment() -> Environment & Mockable {
		return Mock()
	}

	class override func responseMitigator() -> ResponseMitigatable & Mitigator {
		return MitigatorNoPrinting()
	}

	class override func requestMitigator() -> RequestMitigatable & Mitigator {
		return MitigatorNoPrinting()
	}

	/**
	Transform should be overridden because TransFormCoreData is async.
	*/
	class override func transform() -> TransformJSON {
		return TransformJSON()
	}


}

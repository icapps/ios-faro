//
//  FaroCoreDataParent.swift
//  Faro
//
//  Created by Stijn Willems on 29/07/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import CoreData
import Faro


class FaroCoreDataParent: NSManagedObject, Transformable, Mitigatable {


	//MARK: - Transformable
	class func transform() -> TransformJSON {
		return TransformCoreData()
	}

	class func rootKey() -> String? {
		CoreDataError.ProvideARootKey
		return nil
	}

	// MARK: - Mitigatable

	class func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return MitigatorDefault()
	}

	class func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return MitigatorDefault()
	}
}

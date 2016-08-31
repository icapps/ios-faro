//
//  FaroParent.swift
//  Pods
//
//  Created by Stijn Willems on 29/07/16.
//
//

import Foundation

@available(*, deprecated=1.0.0, message="use Faro.")
public class FaroParent: NSObject, UniqueAble, Mitigatable, Transformable, Parsable {

	// MARK: - Parsable

	public required init(json: AnyObject) throws {
		super.init()
		try self.map(json)
	}

	public func toDictionary()-> NSDictionary? {
		return nil
	}

	public func map(json: AnyObject) throws {

	}

	public class func lookupExistingObjectFromJSON(json: AnyObject) -> Self? {
		return nil
	}
	
	// MARK: - UniqueAble

	public var uniqueValue: String?

	// MARK: - Mitigatable

	public class func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return MitigatorDefault()
	}

	public class func requestMitigator() -> protocol<RequestMitigatable, Mitigator> {
		return MitigatorDefault()
	}

	//MARK: - Transfromable
	public class func transform() -> TransformJSON {
		return TransformJSON()
	}

	public class func rootKey() -> String? {
		return nil
	}
}

public class FaroParentSwift {
	
}
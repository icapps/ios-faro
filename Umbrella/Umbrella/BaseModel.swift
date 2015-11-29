//
//  BaseModel.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation

public protocol BaseModel: class {
/**
* Set all properties from the received JSON at initialization
*/
	init(json: AnyObject)
/**
* An url is formed from <ServiceParameter.serverURL+BaseModel.contextPath>.
*/
	static func contextPath() -> String
	
/**
* Override if you want to POST objects as JSON
*/
	func body()-> NSDictionary?
	
/**
* Set all properties from the received JSON
*/
	func importFromJSON(json: AnyObject)
	
}
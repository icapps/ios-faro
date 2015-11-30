//
//  BaseModel.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation

public protocol BaseModel: class {
	
	var objectId: String? {get set}
	
	static func serviceParameters() ->  ServiceParameters
	
/**
* In your implementation create a general ErrorController and if needed an error controller that can handle
* errors from 
*/
	var errorController: ErrorController {get set}
	
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
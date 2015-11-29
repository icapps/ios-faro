//
//  BaseModel.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation

public protocol BaseModel {
	
/**
* An url is formed from <ServiceParameter.serverURL+BaseModel.contextPath>.
*/
	static func contextPath() -> String
	
/**
* Override if you want to POST objects as JSON
*/
	func body()-> NSDictionary?
	
}
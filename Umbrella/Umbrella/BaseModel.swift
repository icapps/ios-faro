//
//  BaseModel.swift
//  Umbrella
//
//  Created by Stijn Willems on 29/11/15.
//  Copyright © 2015 dooz. All rights reserved.
//

import Foundation

public class BaseModel {
/**
* An url is formed from <ServiceParameter.Url.serverURL.rawValue+contextPath>.
*/
	let contextPath: String
	
	public init (contextPath: String) {
		self.contextPath = contextPath
	}
	
	
}
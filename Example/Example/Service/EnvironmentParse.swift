//
//  Parse.swift
//  AirRivet
//
//  Created by Stijn Willems on 04/01/2016.
//  2016 iCapps. MIT Licensed.
//

import AirRivet

/**
This is an example implementation of the protocol `Environment`. 
*/
open class EnvironmentParse <Rivet: EnvironmentConfigurable>: Environment, Mockable {
    
    // MARK: - Environment
    
	open var serverUrl = "https://api.parse.com/1/classes/"
	open var request: NSMutableURLRequest {
		let url = URL(string: "\(serverUrl)\(Rivet.contextPath())")
		let request = NSMutableURLRequest(url: url!)

		// Set the custom authorization headers.
		request.addValue("oze24xbiOCeIdsM11C6MXK2RMLunOmoAWQ5VB6XZ", forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("Bd99hIeNb8sa0ZBIVLYWy9wpCz4Hb5Kvri3NiqBu", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
		return request
	}
    
    // MARK: - Mockable

	open func shouldMock() -> Bool {
		return false
	}
}

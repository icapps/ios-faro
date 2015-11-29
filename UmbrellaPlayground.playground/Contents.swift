//Here you can play around with the Umbrella framework to see if it works

import UIKit
import Umbrella
import XCPlayground

class UmbrellaPlaygroundServiceParameter: ServiceParameter {
	var serverUrl = "https://api.parse.com/1/classes/"
	var request: NSMutableURLRequest {
		let URL = NSURL(string: "\(serverUrl)GameScore")
		let request = NSMutableURLRequest(URL: URL!)
		request.HTTPMethod = "POST"
		
		// Headers
		
		request.addValue("oze24xbiOCeIdsM11C6MXK2RMLunOmoAWQ5VB6XZ", forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("Bd99hIeNb8sa0ZBIVLYWy9wpCz4Hb5Kvri3NiqBu", forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		return request
	}
}

let serviceParameters = UmbrellaPlaygroundServiceParameter()

let test = RequestController(serviceParameters: serviceParameters)

test.sendRequest { (response) -> () in
	let responseData = response
	print(response)
	XCPlaygroundPage.currentPage.finishExecution()
}

//To let async code work
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

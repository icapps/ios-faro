//Here you can play around with the Umbrella framework to see if it works

import UIKit
import Umbrella
import XCPlayground

class UmbrellaPlaygroundServiceParameter: ServiceParameter {
	var serverUrl = "https://api.parse.com/1/classes/"
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

//
//  ParameterSpec.swift
//  Faro
//
//  Created by Stijn Willems on 22/05/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

import Quick
import Nimble

import Faro
@testable import Faro_Example

class ParameterSpec: QuickSpec {

	override func spec() {
		describe("Logic") {

			let dict = ["bla": "foo"]

			it("isUrlcomponent = true") {
				let parameter: Parameter = .urlComponents(dict)

				expect(parameter.isUrlComponents) == true
				expect(parameter.urlComponentsValue?["bla"]) == dict["bla"]
			}

			it("isHeader = true") {
				let parameter: Parameter = .httpHeader(dict)

				expect(parameter.isHeader) == true
				expect(parameter.httpHeaderValue?["bla"]) == dict["bla"]
			}

			it("isJSONArray = true") {
				let parameter: Parameter = .jsonArray([dict])

				expect(parameter.isJSONArray) == true
				expect(parameter.jsonArrayValue?[0]["bla"] as? String) == dict["bla"]
			}

			it("isJSONNode = true") {
				let parameter: Parameter = .jsonNode(dict)

				expect(parameter.isJSONNode) == true
				expect(parameter.jsonNodeValue?["bla"] as? String) == dict["bla"]
			}
		}
	}

}

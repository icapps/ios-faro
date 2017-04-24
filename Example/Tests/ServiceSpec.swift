//
//  ServiceSpec.swift
//  Faro
//
//  Created by Stijn Willems on 20/04/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation

import Quick
import Nimble

import Faro
@testable import Faro_Example

class Uuid: JSONDeserializable, JSONUpdatable {
	var uuid: String

	required init(_ raw: [String: Any]) throws {
		self.uuid = try create("uuid", from: raw)
	}

}

extension Uuid {
	
	func update(_ raw: [String : Any]) throws {
		self.uuid = try create("uuid", from: raw)
	}

}

class ServiceSpec: QuickSpec {

	override func spec() {

		describe("Succes") {

			it("return valid single model for valid json") {
				let mock = MockDeprecatedService(mockDictionary: ["uuid": "mock ok"])
				let service = Service<Uuid>(call: Call(path: ""), deprecatedService: mock)

				service.single { resultFunction in
					expect {try resultFunction().uuid} == "mock ok"
				}
			}

			it("return valid collection model for valid json") {
				let mock = MockDeprecatedService(mockDictionary: [["uuid": "mock ok 1"], ["uuid": "mock ok 2"]])
				let service = Service<Uuid>(call: Call(path: ""), deprecatedService: mock)

				service.collection { resultFunction in
					expect {try resultFunction().flatMap {$0.uuid}} == ["mock ok 1", "mock ok 2"]
				}
			}

		}

		describe("Error") {

			it("single model for invalid json") {
				let invalidMock = MockDeprecatedService(mockDictionary: ["bullshit": "mock ok"])
				let service = Service<Uuid>(call: Call(path: ""), deprecatedService: invalidMock)

				service.single { resultFunction in
					expect {try resultFunction()}.to(throwError(closure: { (error) in
						if let faroError = error as? FaroError {
							switch faroError {
							case .couldNotCreateInstance(ofType: let type, call: _, error: let error):
								expect(type) == "Uuid"
								expect( (error as? FaroDeserializableError)?.emptyValueKey) == "uuid"
							default:
								XCTFail("\(faroError)")
							}
						} else {
							XCTFail("\(error)")
						}

					}))
				}
			}

			it("collection model for invalid json") {
				let mock = MockDeprecatedService(mockDictionary: [["bullshit": "mock ok 1"], ["uuid": "mock ok 2"]])
				let service = Service<Uuid>(call: Call(path: ""), deprecatedService: mock)

				service.collection { resultFunction in
					expect {try resultFunction()}.to(throwError(closure: { (error) in
						if let faroError = error as? FaroError {
							switch faroError {
							case .couldNotCreateInstance(ofType: let type, call: _, error: let error):
								expect(type) == "Uuid"
								expect( (error as? FaroDeserializableError)?.emptyValueKey) == "uuid"
							default:
								XCTFail("\(faroError)")
							}
						} else {
							XCTFail("\(error)")
						}

					}))
				}
			}

		}

	}

}

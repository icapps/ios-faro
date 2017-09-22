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

class Uuid: Decodable, Hashable, Updatable {

	var uuid: String

    enum UuidError: Error {
        case updateError
    }
    // MARK: - Hashable
    var hashValue: Int {return uuid.hashValue}
    static func == (lhs: Uuid, rhs: Uuid) -> Bool {
        return lhs.uuid == rhs.uuid
    }

    func update(_ model: AnyObject) throws {
        guard let model = model as? Uuid else {
            throw Uuid.UuidError.updateError
        }
        uuid = model.uuid
    }

    func update(array: [AnyObject]) throws {
        guard let array = array as? [Uuid] else {
            throw Uuid.UuidError.updateError
        }

        let set = Set(array)

        guard let model = (set.first {$0 == self}) else {
            return
        }
        try update(model)
    }
}

class ServiceSpec: QuickSpec {

	override func spec() {

		describe("Succes") {

			it("return valid single model for valid json") {
                let data = """
                    {"uuid": "mock ok"}
                """.data(using: .utf8)!
				let mock = MockSession(data: data, urlResponse: nil, error: nil)
                let service = Service(call: Call(path: ""), configuration: Configuration(baseURL:""), faroSession: mock)

				service.single { resultFunction in
					expect {try resultFunction().uuid} == "mock ok"
				}
			}

			it("return valid collection model for valid json") {
                let data = """
                    [{"uuid": "mock ok 1"},
                     {"uuid": "mock ok 2"}]
                """.data(using: .utf8)!
                let mock = MockSession(data: data, urlResponse: nil, error: nil)
                let service = Service(call: Call(path: ""), configuration: Configuration(baseURL:""), faroSession: mock)

				service.collection { resultFunction in
					expect {try resultFunction().flatMap {$0.uuid}} == ["mock ok 1", "mock ok 2"]
				}
			}

		}

		describe("Error") {

			it("single model for invalid json") {
                let data = """
                    {"bullshit": "mock ok"}
                """.data(using: .utf8)!
                let mock = MockSession(data: data, urlResponse: nil, error: nil)
                let service = Service(call: Call(path: ""), configuration: Configuration(baseURL:""), faroSession: mock)

				service.perform(Uuid.self) { resultFunction in
					expect {try resultFunction()}.to(throwError(closure: { (error) in
						if let faroError = error as? FaroError {
							switch faroError {
                            case .decodingError(let error, inData: let data, call: _):
                                //TODO
                                break
//                                expect(type) == "Uuid"
//                                expect( (error as? FaroDeserializableError)?.emptyValueKey) == "uuid"
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
                let data = """
                    [{"bullshit": "mock ok 1"},
                     {"uuid": "mock ok 2"}]
                """.data(using: .utf8)!
                let mock = MockSession(data: data, urlResponse: nil, error: nil)
                let service = Service(call: Call(path: ""), configuration: Configuration(baseURL:""), faroSession: mock)

				service.perform([Uuid].self) { resultFunction in
					expect {try resultFunction()}.to(throwError(closure: { (error) in
                        if let faroError = error as? FaroError {
                            switch faroError {
                            case .decodingError(let error, inData: let data, call: _):
                                //TODO
                                break
                                //                                expect(type) == "Uuid"
                            //                                expect( (error as? FaroDeserializableError)?.emptyValueKey) == "uuid"
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

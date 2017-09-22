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
        let httpResponse =  HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 200, httpVersion:nil, headerFields: nil)!
        let configuration = Configuration(baseURL:"")

		describe("Succes") {

			it("return valid single model for valid json") {
                let data = """
                    {"uuid": "mock ok"}
                """.data(using: .utf8)!
				let mock = MockSession(data: data, urlResponse: httpResponse, error: nil)
                let service = Service(call: Call(path: ""), configuration: configuration, faroSession: mock)

				service.perform (Uuid.self) { resultFunction in
					expect {try resultFunction().uuid} == "mock ok"
				}
			}

			it("return valid collection model for valid json") {
                let data = """
                    [{"uuid": "mock ok 1"},
                     {"uuid": "mock ok 2"}]
                """.data(using: .utf8)!
                let mock = MockSession(data: data, urlResponse: httpResponse, error: nil)
                let service = Service(call: Call(path: ""), configuration: configuration, faroSession: mock)

				service.perform ([Uuid].self) { resultFunction in
					expect {try resultFunction().flatMap {$0.uuid}} == ["mock ok 1", "mock ok 2"]
				}
			}

		}

		describe("Error") {

			it("single model with invalid json") {
                let data = """
                    {"bullshit": "mock ok"}
                """.data(using: .utf8)!

                let mock = MockSession(data: data, urlResponse: httpResponse, error: nil)

                let service = Service(call: Call(path: ""), configuration: configuration, faroSession: mock)

				service.perform(Uuid.self) { resultFunction in
					expect {try resultFunction()}.to(throwError {
                        expect(($0 as? ServiceError)?.decodingErrorMissingKey) == "uuid"
					})
				}
			}

			it("collection model for invalid json") {
                let data = """
                    [{"bullshit": "mock ok 1"},
                     {"uuid": "mock ok 2"}]
                """.data(using: .utf8)!
                let mock = MockSession(data: data, urlResponse: httpResponse, error: nil)
                let service = Service(call: Call(path: ""), configuration: configuration, faroSession: mock)

				service.perform([Uuid].self) { resultFunction in
                    expect {try resultFunction()}.to(throwError {
                        expect(($0 as? ServiceError)?.decodingErrorMissingKey) == "uuid"
					})
				}
			}

		}

	}

}

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

class ServiceSpec: QuickSpec {

	override func spec() {
        beforeEach {
            // Config should have a valid url
            let config = BackendConfiguration(baseURL: "http://www.google.com")
            let urlSessionConfig = URLSessionConfiguration.default
            urlSessionConfig.protocolClasses = [StubbedURLProtocol.self]
            FaroURLSession.setup(backendConfiguration: config, urlSessionConfiguration: urlSessionConfig)
            RequestStub.shared = RequestStub()
        }

		describe("Succes") {

			it("return valid single model for valid json") {
                let data = """
                    {"uuid": "mock ok"}
                """.data(using: .utf8)!

                let call = Call(path: "single")

                call.path.stub(statusCode: 200, data: data)

                let service = Service(call: call)

                waitUntil(action: { (done) in
                    service.perform (DecodableMock.self) { resultFunction in
                        expect {try resultFunction().uuid} == "mock ok"
                        done()
                    }
                })
			}

			it("return valid collection model for valid json") {
                let data = """
                    [{"uuid": "mock ok 1"},
                     {"uuid": "mock ok 2"}]
                """.data(using: .utf8)!

                let call = Call(path: "collection")
                call.path.stub(statusCode: 200, data: data)

                let service = Service(call: call)

                waitUntil(action: { (done) in
                    service.perform ([DecodableMock].self) { resultFunction in
                        expect {try resultFunction().flatMap {$0.uuid}} == ["mock ok 1", "mock ok 2"]
                        done()
                    }
                })
			}

		}

		describe("Error") {

			it("single model with invalid json") {
                let data = """
                    {"bullshit": "mock ok"}
                """.data(using: .utf8)!

                // Stub with bullshit data
                let call = Call(path: "singleError")

                call.path.stub(statusCode: 200, data: data)

                let service = Service(call: call)

                waitUntil { done in
                    service.perform(DecodableMock.self) { resultFunction in
                        expect {try resultFunction()}.to(throwError {
                            expect(($0 as? ServiceError)?.decodingErrorMissingKey) == "uuid"
                            done()
                        })
                    }
                }

			}

			it("collection model for invalid json") {
                let data = """
                    [{"bullshit": "mock ok 1"},
                     {"uuid": "mock ok 2"}]
                """.data(using: .utf8)!

                let call = Call(path: "collectionError")
                call.path.stub(statusCode: 200, data: data)

                let service = Service(call: call)

                waitUntil { done in
                    service.perform([DecodableMock].self) { resultFunction in
                        expect {try resultFunction()}.to(throwError {
                            expect(($0 as? ServiceError)?.decodingErrorMissingKey) == "uuid"
                            done()
                        })
                    }
                }

			}

		}

	}

}

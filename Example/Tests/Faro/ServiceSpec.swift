import Quick
import Nimble

import Faro
@testable import Faro_Example

class ServiceSpec: QuickSpec {
    override func spec() {
        describe("MockService result: case defined by configuration") {
            let expected = ["key": "value"]
            var service: Service!

            beforeEach {
                service = MockService(mockJSON: expected)
            }

            it("should return mockModel in sync") {
                let call = Call(path: "mock")
                var isInSync = false
                service.perform(call, result: { (result: Result<MockModel>) in
                    isInSync = true
                    switch result {
                    case .JSON(json: let json):
                        expect(json).to(beIdenticalTo(expected))
                    default:
                        XCTFail("You should succeed")
                    }
                })

                expect(isInSync).to(beTrue())
            }

            it("InvalidAuthentication when statuscode 404") {
                let response = NSHTTPURLResponse(URL: NSURL(), statusCode: 404, HTTPVersion: nil, headerFields: nil)
                service.checkStatusCodeAndData(nil, urlResponse: response, error: nil) { (result: Result<MockModel>) in
                    switch result {
                    case .Failure(let faroError) where faroError == Error.InvalidAuthentication:
                        break
                    default:
                        XCTFail("Should have invalid authentication error")
                    }
                }
            }

            it("Fail for NSError") {
                let nsError = NSError(domain: "tests", code: 101, userInfo: nil)
                service.checkStatusCodeAndData(nil, urlResponse: nil, error: nsError) { (result: Result<MockModel>) in
                    switch result {
                    case .Failure(let faroError):
                        switch faroError {
                        case .ErrorNS(_):
                            break
                        default:
                            XCTFail("Should have invalid authentication error")

                        }
                    default:
                        XCTFail("Should have invalid authentication error")
                    }
                }
            }

            context("no data from service") {
                it("No fail for statuscode 200") {
                    ExpectResponse.statusCode(200, service: service)
                }

                it("No fail for statuscode 201") {
                    ExpectResponse.statusCode(201, service: service)
                }
            }

            context("data from service") {
                it("data returned for statuscode 200") {
                    ExpectResponse.statusCode(200, data: "data".dataUsingEncoding(NSUTF8StringEncoding), service: service)
                }

                it("data returned for statuscode 201") {
                    ExpectResponse.statusCode(201, data: "data".dataUsingEncoding(NSUTF8StringEncoding), service: service)
                }
            }

            describe("Service Asynchronous", {
                it("should fail for a wierd url") {
                    let configuration = Faro.Configuration(baseURL: "wierd")
                    let service = Service(configuration: configuration)
                    let call = Call(path: "posts")

                    var failed = false

                    service.perform(call, result: { (result: Result<MockModel>) in
                        switch result {
                        case .Failure:
                            failed = true
                        default:
                            XCTFail("💣should fail")
                        }
                    })

                    expect(failed).toEventually(beTrue())
                }
            })

            describe("MockService toModelResult: case .Model(model)") {
                var service: Service!
                var mockJSON: AnyObject!

                beforeEach({
                    mockJSON = ["key": "value"]
                    service = MockService(mockJSON: mockJSON)

                })

                it("should have a configuration with the correct baseUrl") {
                    expect(service.configuration.baseURL).to(equal("mockService"))
                }

                it("should return in sync with the mock model") {
                    let call = Call(path: "unitTest")
                    var isInSync = false

                    service.perform(call) { (result: Result<MockModel>) in
                        isInSync = true
                        switch result {
                        case .Model(model: let model):
                            expect(model.value).to(equal("value"))
                        default:
                            XCTFail("You should succeed")
                        }
                    }

                    expect(isInSync).to(beTrue())
                }
            }
        }
    }
}

class ExpectResponse {
    static func statusCode(statusCode: Int, data: NSData? = nil, service: Service) {
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: statusCode, HTTPVersion: nil, headerFields: nil)
        service.checkStatusCodeAndData(data, urlResponse: response, error: nil) { (result: Result<MockModel>) in
            if let data = data {
                switch result {
                case .Data(_):
                    break
                default:
                    XCTFail("Should not fail for statuscode: \(statusCode) data: \(data)")
                }
            } else {
                switch result {
                case .OK:
                    break
                default:
                    XCTFail("Should not fail for statuscode: \(statusCode) data: \(data)")
                }
            }

        }
    }
}
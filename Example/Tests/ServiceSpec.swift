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
            
            it("InvalidAuthentication when statuscode 404") {
                let response =  HTTPURLResponse(url: URL(string: "http://www.test.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
                service.checkStatusCodeAndData(data: nil, urlResponse: response, error: nil) { (result: Result<MockModel>) in
                    switch result {
                    case .failure(let faroError) where faroError == FaroError.invalidAuthentication:
                        break
                    default:
                        XCTFail("Should have invalid authentication error")
                    }
                }
            }

            it("Fail for NSError") {
                let nsError = NSError(domain: "tests", code: 101, userInfo: nil)
                service.checkStatusCodeAndData(data: nil, urlResponse: nil, error: nsError) { (result: Result<MockModel>) in
                    switch result {
                    case .failure(let faroError):
                        switch faroError {
                        case .nonFaroError(_):
                            break
                        default:
                            print("\(faroError)")
                            XCTFail("Should have nserror")
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
                    ExpectResponse.statusCode(200, data: "data".data(using: String.Encoding.utf8), service: service)
                }

                it("data returned for statuscode 201") {
                    ExpectResponse.statusCode(201, data: "data".data(using: String.Encoding.utf8), service: service)
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
                        case .failure:
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
                var mockJSON: Any!

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
                        case .model(model: let model):
                            expect(model?.value).to(equal("value"))
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
    static func statusCode(_ statusCode: Int, data: Data? = nil, service: Service) {
        let response = HTTPURLResponse(url: URL(string: "http://www.test.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        service.checkStatusCodeAndData(data: data, urlResponse: response, error: nil) { (result: Result<MockModel>) in
            if let data = data {
                switch result {
                case .data(_):
                    break
                default:
                    XCTFail("Should not fail for statuscode: \(statusCode) data: \(data)")
                }
            } else {
                switch result {
                case .ok:
                    break
                default:
                    XCTFail("Should not fail for statuscode: \(statusCode) data: \(data)")
                }
            }

        }
    }
}

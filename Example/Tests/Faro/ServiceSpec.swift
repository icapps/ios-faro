import Quick
import Nimble

import Faro
@testable import Faro_Example

class ServiceSpec: QuickSpec {
    override func spec() {
        describe("MockService") {
            let expected = ["key": "value"]
            var service: Service!

            beforeEach {
                service = MockService(mockJSON: expected)
            }

            it("should return mockModel in sync") {
                let order = Order(path: "mock")
                var isInSync = false
                service.serve(order) { (result: Result <MockModel>) in
                    isInSync = true
                    switch result {
                    case .JSON(json: let json):
                        expect(json).to(beIdenticalTo(expected))
                    default:
                        XCTFail("You should succeed")
                    }
                }

                expect(isInSync).to(beTrue())
            }

            it("InvalidAuthentication when statuscode 404") {
                let response = NSHTTPURLResponse(URL: NSURL(), statusCode: 404, HTTPVersion: nil, headerFields: nil)
                checkStatusCodeAndData(nil, urlResponse: response, error: nil) { (result: Result<MockModel>) in
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
                checkStatusCodeAndData(nil, urlResponse: nil, error: nsError) { (result: Result<MockModel>) in
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
                    ExpectResponse.statusCode(200)
                }

                it("No fail for statuscode 201") {
                    ExpectResponse.statusCode(201)
                }
            }

            context("data from service") {
                it("data returned for statuscode 200") {
                    ExpectResponse.statusCode(200, data: "data".dataUsingEncoding(NSUTF8StringEncoding))
                }

                it("data returned for statuscode 201") {
                    ExpectResponse.statusCode(201, data: "data".dataUsingEncoding(NSUTF8StringEncoding))
                }
            }

            describe("JSONService Asynchronous", {
                it("should fail for a wierd url") {
                    let configuration = Faro.Configuration(baseURL: "wierd")
                    let service = JSONService(configuration: configuration)
                    let order = Order(path: "posts")

                    var failed = false

                    service.serve(order) { (result: Result <MockModel>) in
                        switch result {
                        case .Failure:
                            failed = true
                        default:
                            XCTFail("💣should fail")
                        }
                    }

                    expect(failed).toEventually(beTrue())
                }

                it("should return an empty model") {
                    let configuration = Faro.Configuration(baseURL: "http://jsonplaceholder.typicode.com")
                    let service = JSONService(configuration: configuration)
                    let order = Order(path: "posts")

                    var receivedJSON = false

                    service.serve(order) { (result: Result <MockModel>) in
                        switch result {
                        case .JSON(let json):
                            if let json = json as? [[String: AnyObject]] {
                                expect(json.count).to(equal(100))
                                receivedJSON = true
                            } else {
                                XCTFail("\(json) is wrong")
                            }
                        default:
                            XCTFail("💣should return json")
                        }
                    }

                    expect(receivedJSON).toEventually(beTrue())
                }
            })
        }
    }
}

class ExpectResponse {
    static func statusCode(statusCode: Int, data: NSData? = nil) {
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: statusCode, HTTPVersion: nil, headerFields: nil)
        checkStatusCodeAndData(data, urlResponse: response, error: nil) { (result: Result<MockModel>) in
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
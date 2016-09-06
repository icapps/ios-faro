import Quick
import Nimble

import Faro
@testable import Faro_Example

func checkToBeError(expectedError: Error?, service: Service, data: NSData? = nil, response: NSURLResponse? = nil, nsError: NSError? = nil) -> Bool {

    var error: Error?
    let result = { (result: Result <MockModel>) in
        switch result {
        case .Failure(let returnError):
            error = returnError as? Error
        default:
            return
        }
    }
    convertAllThrowsToResult(result) {
        try service.checkStatusCodeAndData(data, urlResponse: response, error: nsError)
    }

    return error == expectedError
}

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
                expect(checkToBeError(Error.InvalidAuthentication, service: service, response: response)).to(beTrue())
            }

            it("Fail for NSError") {
                let expected = NSError(domain: "tests", code: 101, userInfo: nil)
                expect(checkToBeError(Error.Error(expected), service: service, nsError: expected)).to(beTrue())
            }

            it("No fail for statuscode 200") {
                let response = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: nil)
                expect(checkToBeError(nil, service: service, response: response)).to(beTrue())
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

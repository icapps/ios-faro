import Quick
import Nimble

import Faro
@testable import Faro_Example

class PagingInformation: Deserializable {
    var pages: Int
    var currentPage: Int

    required init?(from raw: Any) {
        guard let json = raw as? [String: Any] else {
            return nil
        }
		do {
			pages = try parse("pages", from: json)
			currentPage = try parse("currentPage", from: json)
		} catch {
			print(error)
			return nil
		}
	}
}

class ServiceSpec: QuickSpec {

	//swiftlint:disable cyclomatic_complexity
	override func spec() {

        describe("Mocked session - returning from urlsession task with expected result") {
            var service: Service!
            let call = Call(path: "mock")
            var mockSession: MockSession!

            beforeEach {
                mockSession = MockSession()
                service = Service(configuration: Configuration(baseURL: "mockService"), faroSession: mockSession)
                mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 200, httpVersion:nil, headerFields: nil)
            }

            it("should return in sync") {
                var sync = false

                service.performWrite(call) { _ in
                    sync = true
                }

                expect(sync) == true
            }

            it("should return paging information") {
                var pagesInformation: PagingInformation!

                mockSession.data = "{\"pages\":10, \"currentPage\":25}".data(using: .utf8)

                service.perform(call, page: { (pageInfo) in
                    pagesInformation = pageInfo
                    }, modelResult: { (_: Result<MockModel>) in
                })

                expect(pagesInformation.pages) == 10
            }

            context ("update an existing model") {

                it("when respons contains data") {
					expect {
						let jsonDict = ["uuid": "mockUUID"]
						let mockModel = MockModel(from: jsonDict)!
						let data = try JSONSerialization.data(withJSONObject: jsonDict,
						                                      options: .prettyPrinted)
						mockSession.data = data

						service.perform(call, on: mockModel) { (result: Result<MockModel>) in
							switch result {
							case .model(let model):
								let identical = (model === mockModel)
								expect(identical).to(beTrue())
							default:
								XCTFail("\(result)")
							}
						}
						return true
					}.toNot(throwError())

                }
            }

			context("general error handler") {

				var receivedErrorToRetry: FaroError?

				beforeEach {
					mockSession = MockSession()
					//swiftlint:disable comma
					service = Service(configuration: Configuration(baseURL: ""), faroSession: mockSession, errorHandler: { (error, _, noRetryNeeded) in
						receivedErrorToRetry = error
						noRetryNeeded()
					})
					mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 200, httpVersion:nil, headerFields: nil)
				}

				it("ANY perform should call retry for authorisation 401") {

					mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 401, httpVersion:nil, headerFields: nil)

					var shouldCallResult = false
					service.perform(call, modelResult: { (result: Result<MockModel>) in
						shouldCallResult = true
						expect(result.error?.networkErrorCode) == 401
					})

					expect(shouldCallResult) == true
					expect(receivedErrorToRetry?.networkErrorCode) == 401
				}

				it("WRITE perform should call retry for authorisation 401") {

					mockSession.urlResponse = HTTPURLResponse(url: URL(string: "http://www.google.com")!, statusCode: 401, httpVersion:nil, headerFields: nil)

					var shouldCallResult = false
					service.performWrite(call, writeResult: { (result) in
						shouldCallResult = true
						expect(result.error?.networkErrorCode) == 401
					})

					expect(shouldCallResult) == true
					expect(receivedErrorToRetry?.networkErrorCode) == 401
				}

			}

        }

        describe("Parsing to model") {
            var service: Service!
            var mockJSON: Any!

            context("array of objects response") {
                beforeEach {
                    mockJSON = [["uuid": "object 1"], ["uuid": "object 2"]]
                    service = MockService(mockDictionary: mockJSON)
                }

                it("should respond with array") {
                    let call = Call(path: "unitTest")
                    var isInSync = false

                    service.perform(call) { (result: Result<MockModel>) in
                        isInSync = true
                        switch result {
                        case .models(let models):
                            expect(models?.count).to(equal(2))
                        default:
                            XCTFail("You should succeed")
                        }
                    }

                    expect(isInSync).to(beTrue())
                }
            }

            context("single object response") {
                beforeEach {
                    mockJSON = ["uuid": "object id 1"]
                    service = MockService(mockDictionary: mockJSON)
                }

                it("should have a configuration with the correct baseUrl") {
                    expect(service.configuration.baseURL).to(equal(""))
                }

                it("should return in sync with the mock model") {
                    let call = Call(path: "unitTest")
                    var isInSync = false

                    service.perform(call) { (result: Result<MockModel>) in
                        isInSync = true
                        switch result {
                        case .model(model: let model):
                            expect(model?.uuid).to(equal("object id 1"))
                        default:
                            XCTFail("You should succeed")
                        }
                    }

                    expect(isInSync).to(beTrue())
                }
            }
        }

        describe("MockService responses") {
            let expected = ["key": "value"]
            var service: Service!

            beforeEach {
                service = MockService(mockDictionary: expected)
            }

            context("error cases") {
                it("HttpError when statuscode > 400") {
                    let response =  HTTPURLResponse(url: URL(string: "http://www.test.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)
                    let result = service.handle(data: nil, urlResponse: response, error: nil) as Result<MockModel>
                    switch result {
                    case .failure(let faroError):
                        switch faroError {
                        case .networkError(let statuscode, data: _ ):
                            expect(statuscode) == 404
                            break
                        default:
                            XCTFail("wrong error")
                        }

                        break
                    default:
                        XCTFail("Should have invalid authentication error")
                    }
                }

                it("Fail for NSError") {
                    let nsError = NSError(domain: "tests", code: 101, userInfo: nil)
                    let result = service.handle(data: nil, urlResponse: nil, error: nsError) as Result<MockModel>
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

            context("success cases") {

                context("data in response") {
                    it("data returned for statuscode 200") {
                        ExpectResponse.statusCode(200, data: "data".data(using: String.Encoding.utf8), service: service)
                    }

                    it("data returned for statuscode 201") {
                        ExpectResponse.statusCode(201, data: "data".data(using: String.Encoding.utf8), service: service)
                    }

                    it("data returned for statuscode 204") {
                        ExpectResponse.statusCode(204, data: "data".data(using: String.Encoding.utf8), service: service)
                    }
                }

                context("no data in response") {
                    it("No fail for statuscode 200") {
                        ExpectResponse.statusCode(200, service: service)
                    }

                    it("No fail for statuscode 201") {
                        ExpectResponse.statusCode(201, service: service)
                    }
                }
            }

        }

        /// You might want to disable this because it does requests to the server
        describe("Service Asynchronous", {
            it("should fail for a wierd url") {
                let configuration = Faro.Configuration(baseURL: "wierd")
                let service = Service(configuration: configuration)
                let call = Call(path: "posts")

                var failed = false

                service.perform(call, modelResult: { (result: Result<MockModel>) in
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

    }
}

class ExpectResponse {
    static func statusCode(_ statusCode: Int, data: Data? = nil, service: Service) {
        let response = HTTPURLResponse(url: URL(string: "http://www.test.com")!, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        let result = service.handle(data: data, urlResponse: response, error: nil) as Result<MockModel>
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

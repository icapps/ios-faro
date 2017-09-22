import Quick
import Nimble

import Faro
@testable import Faro_Example

private class AuthorizableCall: Call, Authenticatable {
	static let fakeHeader = ["Authorization": "super secret stuff"]

	func authenticate(_ request: inout URLRequest) {
		request.allHTTPHeaderFields = AuthorizableCall.fakeHeader
	}

}

class CallSpec: QuickSpec {

    override func spec() {

        describe("Call .POST with parameters") {
            let expected = "path"
            let parameters: Parameter = .jsonNode(["id": "someId"])
            let call = Call(path: expected, method: .POST, parameter: [parameters])
            let configuration = Faro.Configuration(baseURL: "http://someURL")

            it("should use POST method") {
                let request = call.request(with: configuration)
                expect(request!.httpMethod) == "POST"
            }
        }

        describe("Call .GET") {
            let expected = "path"
            let call = Call(path: expected)
            let configuration = Faro.Configuration(baseURL: "http://someURL")

            context("setup") {
                it("should have a path") {
                    expect(call.path).to(equal(expected))
                }

                it("should default to .GET") {
                    let request = call.request(with: configuration)!
                    expect(request.httpMethod).to(equal("GET"))
                }

                it("should configuration should make up request") {
                    let request = call.request(with: configuration)!
                    expect(request.url!.absoluteString).to(equal("http://someURL/path"))
                }
            }

            context("Root JSON node extraction") {
                it("should return an object if JSON is single node") {

                    let node = call.rootNode(from: ["key": "value"])
                    switch node {
                    case .nodeObject(let node):
                        expect(node["key"] as? String).to(equal("value"))
                    default:
                        XCTFail("should fetch node")
                    }
                }
            }
        }

        describe("Call .Get with RootNode") {

            let expected = "path"
            let call = Call(path: expected, rootNode: "rootNode")

            it("should extract single object from a rootNode") {
                let node = call.rootNode(from: ["rootNode": ["key": "value"]])
                switch node {
                case .nodeObject(let node):
                    expect(node["key"] as? String).to(equal("value"))
                default:
                    XCTFail("should fetch node")
                }
            }

            it("should extract Array of objects from a rootNode") {
                let node = call.rootNode(from: ["rootNode": [["key": "value"]]])
                switch node {
                case .nodeArray(let nodes):
                    expect(nodes.count).to(equal(1))
                default:
                    XCTFail("should fetch node")
                }
            }

        }

        describe("Call with parameters") {
            let configuration = Faro.Configuration(baseURL: "http://someURL")

            func allHTTPHeaderFields(_ parameter: Parameter) -> [String: String] {
                let call = Call(path: "path", parameter: [parameter])
                let request = call.request(with: configuration)
                return request!.allHTTPHeaderFields!
            }

            func componentString(_ parameter: Parameter) -> String {
                let call = Call(path: "path", parameter: [parameter])
                let request = call.request(with: configuration)
                return request!.url!.absoluteString
            }

            func body(_ parameter: Parameter, method: HTTPMethod) -> Data? {
                let call = Call(path: "path", method: method, parameter: [parameter])
                let request = call.request(with: configuration)
                return request!.httpBody
            }

            it("should insert http headers into the request") {

                let headers = allHTTPHeaderFields(.httpHeader(["Accept-Language": "en-US",
                                                                                  "Accept-Charset": "utf-8"]))
                let keys = Array(headers.keys)
                let values = Array(headers.values)

                expect(keys).to(contain("Accept-Language"))
                expect(values).to(contain("utf-8"))
            }

            context("\(Parameter.urlComponentsInURL(["": ""]))") {
                it("insert") {
                    let string = componentString(.urlComponentsInURL(["some query item": "aa🗿🤔aej"]))
                    expect(string).to(contain("some%20query%20item=aa%F0%9F%97%BF%F0%9F%A4%94aej"))
                }

                it("insert sorted") {
                    let string = componentString(.urlComponentsInURL(["X": "X", "B": "B", "A": "A"]))
                    expect(string).to(contain("?A=A&B=B&X=X"))
                }
            }

            let bodyJson = ["a string": "good day i am a string",
                            "a number": 123] as [String : Any]

            context("should add JSON into httpBody for") {

				it("PUT or POST with urlComponents Body") {
					if let data = body(.urlComponentsInBody(["key": "value with spaces"]), method: .PUT) {
						let dataString = String(data: data, encoding: .utf8)

						expect(dataString) == "key=value%20with%20spaces"
					} else {
						XCTFail()
					}
				}

                it("PUT") {
					expect {
						if let data = body(.jsonNode(bodyJson), method: .PUT) {
							let jsonDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]

                            expect(jsonDict?.keys.flatMap {$0}.sorted(by: >)) == ["a string", "a number"]
						} else {
							XCTFail()
						}
						return true
					}.toNot(throwError())
				}

                it("POST") {
					expect {
						if let data = body(.jsonNode(bodyJson), method: .POST) {
							let jsonDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]

							expect(jsonDict?.keys.flatMap {$0}.sorted(by: >)) == ["a string", "a number"]
						} else {
							XCTFail()
						}
						return true
					}.toNot(throwError())
                }

                it("DELETE") {
					expect {
						if let data = body(.jsonNode(bodyJson), method: .DELETE) {
							let jsonDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]

							expect(jsonDict?.keys.count).to(equal(2))
						} else {
							XCTFail()
						}
						return true
					}.toNot(throwError())

                }

            }

            it("should fail to add JSON into a GET") {
                let data = body(.jsonNode(bodyJson), method: .GET)
                expect(data).to(beNil())
            }

            it("should not produce invalid URL's when given empty parameters") {
                let parameters = [String: String]()
                let callString: String = componentString(.urlComponentsInURL(parameters))
                expect(callString.characters.last) != "?"
            }

            it("should not produce invalid URL's when given parameters with missing keys") {
                let parameters = ["": "aValue"]
                let callString: String = componentString(.urlComponentsInURL(parameters))
                expect(callString.characters.last) != "?"
            }

            it("should not produce invalid URL's when given parameters with missing values") {
                let parameters = ["aKey": ""]
                let callString: String = componentString(.urlComponentsInURL(parameters))
                expect(callString.characters.last) != "?"
            }
        }

		describe("Authorised Call") {

			var call: AuthorizableCall!

			beforeEach {
				call = AuthorizableCall(path: "", method: .GET, rootNode: nil, parameter: nil)
			}

			it("has authorization header") {
				let request = call.request(with: Configuration(baseURL: ""))

				let header = request?.allHTTPHeaderFields?.filter {$0.key == "Authorization"}

				expect(header?.first?.value) == AuthorizableCall.fakeHeader.first?.value
			}
		}
    }

}

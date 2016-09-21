import Quick
import Nimble

import Faro
@testable import Faro_Example

class CallSpec: QuickSpec {

    override func spec() {
        describe("Call .GET") {
            let expected = "path"
            let call = Call(path: expected)
            let configuration = Faro.Configuration(baseURL: "http://someURL")

            context("setup") {
                it("should have a path") {
                    expect(call.path).to(equal(expected))
                }

                it("should default to .GET") {
                    let request = call.request(withConfiguration: configuration)!
                    expect(request.httpMethod).to(equal("GET"))
                }

                it("should configuration should make up request") {
                    let request = call.request(withConfiguration: configuration)!
                    expect(request.url!.absoluteString).to(equal("http://someURL/path"))
                }
            }

            context("Root JSON node extraction") {
                it("should return an object if JSON is single node") {

                    let node = call.rootNode(from: ["key": "value"])
                    switch node {
                    case .nodeObject(let node):
                        expect(node["key"] as! String?).to(equal("value"))
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
                    expect(node["key"] as! String?).to(equal("value"))
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

            it("should insert http headers into the request") {
                let params = Parameters(type: .httpHeader, parameters: ["Accept-Language" : "en-US",
                                                                                                "Accept-Charset" : "utf-8"])
                let call = Call(path: "path", method: .GET, rootNode: nil, parameters: params)
                let request = call.request(withConfiguration: configuration)
                expect(request?.allHTTPHeaderFields?.keys).to(contain("Accept-Language"))
                expect(request?.allHTTPHeaderFields?.values).to(contain("utf-8"))
            }
            
            it("should fail to insert http headers that arent strings into the request") {
                let params = Parameters(type: .httpHeader, parameters: ["Accept-Language" : 12345,
                                                                                                "Accept-Charset" : Data(base64Encoded: "el wrongo")])
                let call = Call(path: "path", method: .GET, rootNode: nil, parameters: params)
                let request = call.request(withConfiguration: configuration)
                expect(request?.allHTTPHeaderFields?.keys).toNot(contain("Accept-Language"))
                expect(request?.allHTTPHeaderFields?.values).toNot(contain("utf-8"))
            }
            
            it("should insert URL components into the request") {
                let params = Parameters(type: .urlComponents, parameters: ["some query item": "aa🗿🤔aej"])
                let call = Call(path: "path", method: .GET, rootNode: nil, parameters: params)
                let request = call.request(withConfiguration: configuration)
                expect(request?.url?.absoluteString).to(contain("some%20query%20item=aa%F0%9F%97%BF%F0%9F%A4%94aej"))
            }
            
            it("should fail to insert URL components that arent strings into the request") {
                let params = Parameters(type: .urlComponents, parameters: ["some dumb query item": Data(base64Encoded: "el wrongo")])
                let call = Call(path: "path", method: .GET, rootNode: nil, parameters: params)
                let request = call.request(withConfiguration: configuration)
                expect(request?.url?.absoluteString).toNot(contain("some%20dumb%20query%20item"))
            }
            
            it("should add JSON into the request body into the request") {
                let params = Parameters(type: .jsonBody, parameters: ["a string": "i am a string. well met.",
                                                                                              "a number": 123])
                let call = Call(path: "path", method: .PUT, rootNode: nil, parameters: params)
                let data = call.request(withConfiguration: configuration)?.httpBody
                expect(data).toNot(beNil())
                
                do {
                    guard let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
                        XCTFail("not a dict")
                        return
                    }
                    expect(jsonDict).toNot(beNil())
                    expect(jsonDict.keys.count).to(equal(2))
                } catch {
                    XCTFail("should have been in correct format")
                }
                
            }
            
            it("should fail to add JSON into a GET or DELETE request") {
                let params = Parameters(type: .jsonBody, parameters: ["a string": "good day i am a string",
                                                                                              "a number": 123])
                let call = Call(path: "path", method: .GET, rootNode: nil, parameters: params)
                let data = call.request(withConfiguration: configuration)?.httpBody
                expect(data).to(beNil())
            }
        }
    }

}

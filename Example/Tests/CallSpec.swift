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
    }

}

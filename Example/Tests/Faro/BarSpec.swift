import Quick
import Nimble

import Faro
@testable import Faro_Example


class MockModel : Parseable {
    var value : String

    required init(json : AnyObject) {
        if let json = json as? [String : String] {
            value = json["key"]!
        }else {
            value = ""
        }
    }
}

class BarSpec: QuickSpec {
    override func spec() {
        describe("Bar") {
            context("success") {
                var baseURL : String!
                var service : UnitTestService!
                var configuration : Faro.Configuration!
                var bar : Bar!
                var mockJSON: AnyObject!

                beforeEach({
                    mockJSON = ["key" : "value"]
                    baseURL = "http://www.something.be"
                    service = UnitTestService(mockJSON: mockJSON)
                    configuration = Configuration(baseURL: baseURL)
                    bar = Bar(configuration: configuration, service: service)
                    
                })

                it("should have a configuration with the correct baseUrl"){
                    expect(bar.configuration.baseURL).to(equal(baseURL))
                }

                it("should have a service") {
                    expect(bar.service).toNot(beNil())
                }

                it("should return in sync with the mock model") {
                    let order = Order(path: "unitTest")
                    var isInSync = false

                    bar.serve(order) { (result : Result <MockModel>) in
                        isInSync = true
                        switch result {
                        case .Success(let model):
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

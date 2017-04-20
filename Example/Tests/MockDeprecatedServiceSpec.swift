import Quick
import Nimble

import Faro
@testable import Faro_Example

class MockDeprecatedServiceSpec: QuickSpec {

    override func spec() {
        describe("MockDeprecatedService") {
            context("dictionary set") {
                var mockDeprecatedService: MockDeprecatedService!

                beforeEach {
                    mockDeprecatedService = MockDeprecatedService()
                }

                it("should return dictionary after perform") {
                    let uuid = "dictionary for testing"
                    mockDeprecatedService.mockDictionary = ["uuid": uuid]

                    mockDeprecatedService.perform(Call(path: "unit tests")) { (result: Result<MockModel>) in
                        switch result {
                        case .model( let model):
                            expect(model!.uuid) == uuid
                        default:
                            XCTFail("should provide a model")
                        }
                    }
                }
            }

            context("JSON file in asset catalog") {
                var mockDeprecatedService: MockDeprecatedService!

                beforeEach {
                    mockDeprecatedService = MockDeprecatedService()
                }

                it("JSON node") {
                    let uuid = "some id"

                    mockDeprecatedService.perform(Call(path: "mockJsonNode")) { (result: Result<MockModel>) in
                        switch result {
                        case .model( let model):
                            expect(model!.uuid) == uuid
                        default:
                            XCTFail("should provide a model")
                        }
                    }
                }

                it("ARRAY of JSON nodes") {
                    mockDeprecatedService.perform(Call(path: "mockJsonArray")) { (result: Result<MockModel>) in
                        switch result {
                        case .models( let models):
                            expect(models!.count) == 3
                        default:
                            XCTFail("should provide an array")
                        }
                    }
                }
            }
        }
    }

}

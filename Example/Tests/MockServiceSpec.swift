import Quick
import Nimble

import Faro
@testable import Faro_Example

class MockServiceSpec: QuickSpec {

    override func spec() {
        describe("MockService") {
            context("dictionary set") {
                var mockService: MockService!

                beforeEach {
                    mockService = MockService()
                }

                it("should return dictionary after perform") {
                    let uuid = "dictionary for testing"
                    mockService.mockDictionary = ["uuid": uuid]

                    mockService.perform(Call(path: "unit tests")) { (result: Result<MockModel>) in
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
                var mockService: MockService!

                beforeEach {
                    mockService = MockService()
                }

                it("JSON node") {
                    let uuid = "some id"

                    mockService.perform(Call(path: "mockJsonNode")) { (result: Result<MockModel>) in
                        switch result {
                        case .model( let model):
                            expect(model!.uuid) == uuid
                        default:
                            XCTFail("should provide a model")
                        }
                    }
                }

                it("ARRAY of JSON nodes") {
                    mockService.perform(Call(path: "mockJsonArray")) { (result: Result<MockModel>) in
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

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

					expect {
						try mockService.perform(Call(path: "unit tests"), success: { (result: Success<MockModel>) in
							return expect(try result.singleModel().uuid) == uuid
						}) {_ in XCTFail()}
						return true
					}.toNot(throwError())

                }
            }

            context("JSON file in asset catalog") {
                var mockService: MockService!

                beforeEach {
                    mockService = MockService()
                }

                it("JSON node") {
                    let uuid = "some id"

					expect {
						try mockService.perform(Call(path: "mockJsonNode"), success: { (result: Success<MockModel>) in
							expect(try result.singleModel().uuid) == uuid
						}) {_ in XCTFail()}
						return true
					}.toNot(throwError())

                }

                it("ARRAY of JSON nodes") {
					expect {
						try mockService.perform(Call(path: "mockJsonArray"), success: { (result: Success<MockModel>) in
							expect(try result.arrayModels().count) == 3
						})
						return true
					}.toNot(throwError())
                }
            }
        }
    }

}

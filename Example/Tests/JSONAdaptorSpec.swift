import Quick
import Nimble

@testable import Faro

class JSONAdaptorSpec: QuickSpec {

    override func spec() {
        describe("JSONAdaptor") {

            it("should return an empty model") {
                let adaptor = JSONAdaptor()

                var receivedJSON = false

                let dataResult: Result<MockModel> = Result.Data("{\"key\":100}".dataUsingEncoding(NSUTF8StringEncoding)!)
                adaptor.serialize(fromDataResult: dataResult, result: { (result: Result<MockModel>) in
                    switch result {
                    case .JSON(let json):
                        if let json = json as? [String: Int] {
                            expect(json["key"]).to(equal(100))
                            receivedJSON = true
                        } else {
                            XCTFail("\(json) is wrong")
                        }
                    default:
                        XCTFail("💣should return json")
                    }
                })

                expect(receivedJSON).toEventually(beTrue())
            }
        }
    }

}

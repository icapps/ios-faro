import XCTest
import Nimble
import Quick

import Faro
@testable import Faro_Example

// MARK: - Mocks

class MockEntityWithErrorMitigator: GameScore {
    override class func environment() -> protocol<Environment, Mockable> {
        return MockEnvironment()
    }
    
    override func map(json: AnyObject) throws  {
        if let _ = json["wrong"] {
            throw ResponseError.InvalidDictionary(dictionary: json as! [String : AnyObject])
        }else {
			return try super.map(json)
        }
    }

    override class func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
        return MockMitigator()
    }
	
}

class MockMitigator: MitigatorNoPrinting {
    override func invalidDictionary(dictionary: AnyObject) throws -> AnyObject?{
        return dictionary["writeNode"]
    }
}

// MARK: - Specs

class ResponseSpec: QuickSpec {

	override func spec () {
		describe ("Response controller  ") {
            
			it("should fail when JSON is invalid") {
				let invalidDict = ["wrong": "json"]
				let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)

				Response().respond(data, succeed: { (response: MockEntity) in
					XCTFail()
                }, fail: { (error) in
                    switch error {
                    case ResponseError.InvalidDictionary(dictionary: _):
                        break
                    default:
                        XCTFail("Wrong type of error \(error)")
                    }
				})
			}

			context("Mocking the Mitigator") {

				it("should succeed with invalid json if the mitigator handles the error") {
					let expectedObjectId = "expectedObjectId"
					let invalidDict = ["wrong": "json", "writeNode": ["uniqueValue":expectedObjectId]]
					let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)

					Response().respond(data, succeed: { (response: MockEntityWithErrorMitigator) in
						expect(response.uniqueValue).to(equal(expectedObjectId))
                    }, fail: { (error) in
                        XCTFail("Should not raise \(error)")
					})
				}

                it("Should succeed with invalid json if the mitigator handles the error with an array") {
                    let expectedObjectId = "expectedObjectId"
                    let expectedObjectId2 = "expectedObjectId2"
                    let invalidDict = ["wrong": "json", "writeNode": [["objectId":expectedObjectId], ["objectId":expectedObjectId2]]]
                    let data = try! NSJSONSerialization.dataWithJSONObject(invalidDict, options: .PrettyPrinted)
                    
                    Response().respond(data, succeed: { (result: [MockEntityWithErrorMitigator]) in
                        expect(result[0].uniqueValue).to(equal(expectedObjectId))
                        expect(result[1].uniqueValue).to(equal(expectedObjectId2))
                        expect(result.count).to(equal(2))
                    }, fail: { (error) in
                        print("Error occured \(error)")
                    })
                }
                
			}
		}
	}

}

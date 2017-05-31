//
//  TransformJSONTests.swift
//  AirRivet
//
//  Created by Hans Van Herreweghe on 21/04/16.
//  2016 iCapps. MIT Licensed.
//

import XCTest
import Nimble
import Quick
import CoreData

import AirRivet
@testable import AirRivet_Example

class MockModel: UniqueAble, Mitigatable, Parsable {
    
    var uniqueValue: String?

	required init(json: Any, managedObjectContext: NSManagedObjectContext? = MockModel.managedObjectContext()) throws {
		try self.map(json)
	}
	
    func map(_ json: Any) throws {
        if let
            json = json as? NSDictionary,
            let identifier = json["identifier"] as? String {
            self.uniqueValue = identifier
		} else {
			throw ResponseError.invalidDictionary(dictionary: json)
		}
    }
    
    func toDictionary()-> NSDictionary? {
        return [
            "identifier": uniqueValue!,
        ]
    }

	class func managedObjectContext() -> NSManagedObjectContext? {
		return nil
	}

	static func lookupExistingObjectFromJSON(_ json: Any, managedObjectContext: NSManagedObjectContext?) -> Self? {
		return nil
	}


	static func rootKey() -> String? {
		return "results"
	}

	class func responseMitigator() -> ResponseMitigatable & Mitigator {
		return MitigatorNoPrinting()
	}

	class func requestMitigator()-> RequestMitigatable & Mitigator {
		return MitigatorNoPrinting()
	}
}

extension MockModel: EnvironmentConfigurable {

	class func contextPath() -> String {
		return "something"
	}
	
	class func environment() -> Environment & Mockable {
		return Mock()
	}
    
}

// MARK: - Specs

class TransformJSONSpec: QuickSpec {
    
	fileprivate func loadDataFromUrl(_ url: String) throws -> Data? {
		guard
			let path = Bundle.main.path(forResource: url, ofType: "json"),
			let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
				XCTFail("problem loading json")
				return nil
		}
		return data
	}
    
    //MARK: transform
    
    override func spec() {
        let transformController = TransformJSON()
        var data = Data()
        
        describe("TransformJSON") {

            it("should not return error at loadingData") {
                expect {try data = self.loadDataFromUrl("exampleBaseModel")!}.notTo(throwError())
            }
            
            it ("should return correct uniqueValue at transformation"){
                try! transformController.transform(data, succeed: {
                    (model: MockModel) in
					expect(model.uniqueValue).to(equal("123456ABCdef"))
                })
            }
            
            it("should not return error at parseFromDict") {
				expect{ try MockModel(json:["identifier" : "test123"])}.notTo(throwError())
            }

            it("should return correct uniqueValue at transform with body") {
                expect {try data = self.loadDataFromUrl("exampleBaseModel")!}.notTo(throwError())
                
                try! transformController.transform(data, succeed: {
					(result : MockModel) in
					expect(result.uniqueValue).to(equal("123456ABCdef"))
                })
            }

            it("should throw error at transform with wrong data") {
                var random = NSInteger(arc4random_uniform(99) + 1)
                data = NSData(bytes: &random, length: 3) as Data
                
                expect { try transformController.transform(data, succeed: { (model : MockModel) in
                    XCTFail("Should not complete") 
                })}.to(throwError(closure: { (error) in
                    let error = error as Error
                    expect(error._code).to(equal(3840))
                }))
            }

            it("should not throw errror at transform with array of objects") {
                expect{ try data = self.loadDataFromUrl("exampleBaseModelResultsArray")!}.notTo(throwError())
                try! transformController.transform(data, succeed: { (results: [MockModel]) in
                    expect{results.count}.to(equal(3))
                    expect{results[0].uniqueValue}.to(equal("123a"))
                    expect{results[1].uniqueValue}.to(equal("456b"))
                    expect{results[2].uniqueValue}.to(equal("789c"))
                })
            }

            it ("should throw error at transform with invalid root key") {
                expect{ try data = self.loadDataFromUrl("exampleBaseModelResultsArrayCustomRootKey")!}.notTo(throwError())
                expect { try transformController.transform(data, succeed: { (model : [MockModel]) in
                    XCTFail("Should not complete") 
                })}.to(throwError(closure: { (error) in
					switch error {
					case ResponseError.invalidDictionary(dictionary: _):
						break
					default :
						XCTFail("Should not be error of type \(error)")
					}
                }))
            }

            it("should not throw error at transform with single item") {
                expect{ try data = self.loadDataFromUrl("exampleBaseModelResultsArray")!}.notTo(throwError())
                try! transformController.transform(data, succeed: {(results: [MockModel]) in
                    expect(results.count).to(equal(3))
                    expect(results[0].uniqueValue).to(equal("123a"))
                })
            }
            
            it("should throw error at transform an array with wrong data") {
                var random = NSInteger(arc4random_uniform(99) + 1)
                data = NSData(bytes: &random, length: 3) as Data
                
                expect { try transformController.transform(data, succeed: { (model : [MockModel]) in
                                        XCTFail("Should not complete")
                })}.to(throwError(closure: { (error) in
                    let error = error as Error
                    expect(error._code).to(equal(3840))
                }))
            }

            context("Foundation object", { 
				it("should return JSON when valid JSON data is provided", closure: {
					let key = "rootKey"
					let value = "valid json"

					let dict = [key: value]

					let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)

					let json = try! transformController.foundationObjectFromData(jsonData, rootKey: nil, mitigator: MitigatorDefault()) as! [String:String]

					expect(json[key]).to(equal(value))

				})
			})
        }
    }
}

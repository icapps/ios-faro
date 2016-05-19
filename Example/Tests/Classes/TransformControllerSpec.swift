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

@testable import AirRivet

class ExampleBaseModel: UniqueAble, Mitigatable, Parsable {
    
    var objectId: String?

	required init(json: AnyObject, managedObjectContext: NSManagedObjectContext? = ExampleBaseModel.managedObjectContext()) throws {
		try self.map(json)
	}
	
    func map(json: AnyObject) throws {
        if let
            json = json as? NSDictionary,
            identifier = json["identifier"] as? String {
            self.objectId = identifier
		} else {
			throw ResponseError.InvalidDictionary(dictionary: json)
		}
    }
    
    func toDictionary()-> NSDictionary? {
        return [
            "identifier": objectId!,
        ]
    }

	class func managedObjectContext() -> NSManagedObjectContext? {
		return nil
	}

	static func rootKey() -> String? {
		return "results"
	}

	class func responseMitigator() -> protocol<ResponseMitigatable, Mitigator> {
		return DefaultMitigator()
	}

	class func requestMitigator()-> protocol<RequestMitigatable, Mitigator> {
		return DefaultMitigator()
	}
}

extension ExampleBaseModel: EnvironmentConfigurable {

	class func contextPath() -> String {
		return "something"
	}
	
	class func environment() -> protocol<Environment, Mockable> {
		return EnvironmentParse<GameScore>() 
	}
    
}

// MARK: - Specs

class TransformJSONSpec: QuickSpec {
    
	private func loadDataFromUrl(url: String) throws -> NSData? {
		guard
			let path = NSBundle.mainBundle().pathForResource(url, ofType: "json"),
			let data = NSData(contentsOfFile: path) else {
				XCTFail("problem loading json")
				return nil
		}
		return data
	}
    
    //MARK: transform
    
    override func spec() {
        let transformController = TransformJSON()
        var data = NSData()
        
        describe("TransformJSON") {

            it("should not return error at loadingData") {
                expect {try data = self.loadDataFromUrl("exampleBaseModel")!}.notTo(throwError())
            }
            
            it ("should return correct objectId at transformation"){
                try! transformController.transform(data, succeed: {
                    (model: ExampleBaseModel) in
					expect(model.objectId).to(equal("123456ABCdef"))
                })
            }
            
            it("should not return error at parseFromDict") {
				expect{ try ExampleBaseModel(json:["identifier" : "test123"])}.notTo(throwError())
            }
            
            it("should return correct objectId at transform with body") {
                expect {try data = self.loadDataFromUrl("exampleBaseModel")!}.notTo(throwError())
                
                try! transformController.transform(data, succeed: {
					(result : ExampleBaseModel) in
					expect(result.objectId).to(equal("123456ABCdef"))
                })
            }
            
            it("should throw error at transform with wrong data") {
                var random = NSInteger(arc4random_uniform(99) + 1)
                data = NSData(bytes: &random, length: 3)
                
                expect { try transformController.transform(data, succeed: { (model : ExampleBaseModel) in
                    XCTFail("Should not complete") 
                })}.to(throwError(closure: { (error) in
                    let error = error as NSError
                    expect(error.code).to(equal(3840))
                }))
            }
            
            it("should not throw errror at transform with array of objects") {
                expect{ try data = self.loadDataFromUrl("exampleBaseModelResultsArray")!}.notTo(throwError())
                try! transformController.transform(data, succeed: { (results: [ExampleBaseModel]) in
                    expect{results.count}.to(equal(3))
                    expect{results[0].objectId}.to(equal("123a"))
                    expect{results[1].objectId}.to(equal("456b"))
                    expect{results[2].objectId}.to(equal("789c"))
                })
            }

            it ("should throw error at transform with invalid root key") {
                expect{ try data = self.loadDataFromUrl("exampleBaseModelResultsArrayCustomRootKey")!}.notTo(throwError())
                expect { try transformController.transform(data, succeed: { (model : [ExampleBaseModel]) in
                    XCTFail("Should not complete") 
                })}.to(throwError(closure: { (error) in
					switch error {
					case ResponseError.InvalidDictionary(dictionary: _):
						break
					default :
						XCTFail("Should not be error of type \(error)")
					}
                }))
            }
            
            it("should not throw error at transform with single item") {
                expect{ try data = self.loadDataFromUrl("exampleBaseModel")!}.notTo(throwError())
                try! transformController.transform(data, succeed: {(results: [ExampleBaseModel]) in
                    expect(results.count).to(equal(1))
                    expect(results[0].objectId).to(equal("123456ABCdef"))
                })
            }
            
            it("should throw error at transform an array with wrong data") {
                var random = NSInteger(arc4random_uniform(99) + 1)
                data = NSData(bytes: &random, length: 3)
                
                expect { try transformController.transform(data, succeed: { (model : [ExampleBaseModel]) in
                                        XCTFail("Should not complete")
                })}.to(throwError(closure: { (error) in
                    let error = error as NSError
                    expect(error.code).to(equal(3840))
                }))
            }

            context("Foundation object", { 
				it("should return JSON when valid JSON data is provided", closure: {
					let key = "rootKey"
					let value = "valid json"

					let dict = [key: value]

					let jsonData = try! NSJSONSerialization.dataWithJSONObject(dict, options: .PrettyPrinted)

					let json = try! transformController.foundationObjectFromData(jsonData, rootKey: nil, mitigator: DefaultMitigator()) as! [String:String]

					expect(json[key]).to(equal(value))

				})
			})
        }
    }
}

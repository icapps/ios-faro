//
//  TransformControllerTests.swift
//  AirRivet
//
//  Created by Hans Van Herreweghe on 21/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import AirRivet

class ExampleBaseModel: UniqueAble, ErrorControlable, Parsable {
    var objectId: String?

	required init (){

	}
	
    required init(json: AnyObject) {
        importFromJSON(json)
    }
    
    func importFromJSON(json: AnyObject) {
        if let json = json as? NSDictionary,
            identifier = json["identifier"] as? String {
                self.objectId = identifier
        }
    }
    
    func body()-> NSDictionary? {
        return [
            "identifier": objectId!,
        ]
    }

	static func rootKey() -> String? {
		return "results"
	}
}
extension ExampleBaseModel: EnvironmentConfigurable {

	func contextPath() -> String {
		return "something"
	}
	
	func environment() -> protocol<Environment, Mockable, Transformable> {
		return Parse<GameScore>() //TODO make this a mock
	}
}

class TransformControllerTests: XCTestCase {

	private func loadDataFromUrl(url: String) -> NSData? {
		guard
			let path = NSBundle.mainBundle().pathForResource(url, ofType: "json"),
			let data = NSData(contentsOfFile: path) else {
				XCTFail("problem loading json")
				return nil
		}
		return data
	}
    //MARK: transform

    func testObjectDataToConcreteObjectNoExistingModel() {
        let transformController = TransformController()
        
		guard let data = loadDataFromUrl("exampleBaseModel") else {
			return
		}
        
        do {
            try transformController.transform(data, completion: { (model:ExampleBaseModel) in
                XCTAssertEqual(model.objectId, "123456ABCdef")
            })
        }
        catch {
            XCTFail("transformation should not throw an error")
        }
    }
    
    func testObjectDataToConcreteObjectWithExistingModel() {
        let transformController = TransformController()
        let inputModel:ExampleBaseModel = ExampleBaseModel(json: ["identifier":"test123"])
        
		guard let data = loadDataFromUrl("exampleBaseModel") else {
			return
		}

        do {
            try transformController.transform(data, body:inputModel, completion: { (model:ExampleBaseModel) in
                XCTAssertEqual(model.objectId, "123456ABCdef")
            })
        }
        catch {
            XCTFail("transformation should not throw an error")
        }
    }
    
    func testObjectDataToConcreteObjectInvalidJSONData() {
        let transformController = TransformController()
        
        //Just generate some random data
        var random = NSInteger(arc4random_uniform(99) + 1)
        let data = NSData(bytes: &random, length: 3)

        XCTAssertThrowsError(try transformController.transform(data, completion: { (model:ExampleBaseModel) in
            XCTFail("transformation of invalid json data should not result in a model object")
        }), "transformation of invalid json data should throw an error") { (error) in
            guard let thrownError = error as? TransformError else {
                XCTFail("wrong error type")
                return
            }
            switch thrownError {
            case .JSONError:
                XCTAssertTrue(true)
            default:
                XCTFail("wrong error type")
            }
        }
    }
    
    //MARK: transform
    
    func testObjectDataToConcreteObjects() {
        let transformController = TransformController()
        
		guard let data = loadDataFromUrl("exampleBaseModelResultsArray") else {
			return
		}

        do {
            try transformController.transform(data, completion: { (results:[ExampleBaseModel]) in
                XCTAssertTrue(results.count == 3)
                XCTAssertEqual(results[0].objectId, "123a")
                XCTAssertEqual(results[1].objectId, "456b")
                XCTAssertEqual(results[2].objectId, "789c")
            })
        }
        catch {
            XCTFail("transformation should not throw an error")
        }
    }
    
//    func testObjectDataToConcreteObjectsCustomRootKey() {
//        let transformController = TransformController()
//        
//        guard
//            let path = NSBundle.mainBundle().pathForResource("exampleBaseModelResultsArrayCustomRootKey", ofType: "json"),
//            let data = NSData(contentsOfFile: path) else {
//                XCTFail("problem loading json")
//                return
//        }
//        
//        do {
//            try transformController.transform(data, completion: { (results:[ExampleBaseModel]) in
//                XCTAssertTrue(results.count == 3)
//                XCTAssertEqual(results[0].objectId, "123a")
//                XCTAssertEqual(results[1].objectId, "456b")
//                XCTAssertEqual(results[2].objectId, "789c")
//            })
//        }
//        catch {
//            XCTFail("transformation should not throw an error")
//        }
//    }

    func testObjectDataToConcreteObjectsFromSingleItem() {
        let transformController = TransformController()
        
		guard let data = loadDataFromUrl("exampleBaseModel") else {
			return
		}
		
        do {
            try transformController.transform(data, completion: { (results:[ExampleBaseModel]) in
                XCTAssertTrue(results.count == 1)
                XCTAssertEqual(results[0].objectId, "123456ABCdef")
            })
        }
        catch {
            XCTFail("transformation should not throw an error")
        }
    }
    
    func testObjectDataToConcreteObjectsInvalidJSONData() {
        let transformController = TransformController()
        
        //Just generate some random data
        var random = NSInteger(arc4random_uniform(99) + 1)
        let data = NSData(bytes: &random, length: 3)
        
        XCTAssertThrowsError(try transformController.transform(data, completion: { (results:[ExampleBaseModel]) in
            XCTFail("transformation of invalid json data should not result in a model object")
        }), "transformation of invalid json data should throw an error") { (error) in
            guard let thrownError = error as? TransformError else {
                XCTFail("wrong error type")
                return
            }
            switch thrownError {
            case .JSONError:
                XCTAssertTrue(true)
            default:
                XCTFail("wrong error type")
            }
        }
    }
}

//
//  TransformControllerTests.swift
//  AirRivet
//
//  Created by Hans Van Herreweghe on 21/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import AirRivet

class ExampleBaseModel: UniqueAble, EnvironmentConfigurable,  ErrorControlable, Parsable {
    var objectId: String?

	required init (){

	}
	
    required init(json: AnyObject) {
        importFromJSON(json)
    }
    
    static func contextPath() -> String {
        return "something"
    }
    
    static func environment() -> Environment {
        return ParseExampleService<GameScore>()
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
}
extension ExampleBaseModel: Mockable {
	func shouldMock() -> Bool {
		return true
	}
}

class TransformControllerTests: XCTestCase {
    
    //MARK: objectDataToConcreteObject
    
    func testObjectDataToConcreteObjectNoExistingModel() {
        let transformController = TransformController()
        
        guard
            let path = NSBundle.mainBundle().pathForResource("exampleBaseModel", ofType: "json"),
            let data = NSData(contentsOfFile: path) else {
                XCTFail("problem loading json")
                return
        }
        
        do {
            try transformController.objectDataToConcreteObject(data, completion: { (model:ExampleBaseModel) in
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
        
        guard
            let path = NSBundle.mainBundle().pathForResource("exampleBaseModel", ofType: "json"),
            let data = NSData(contentsOfFile: path) else {
                XCTFail("problem loading json")
                return
        }
        
        do {
            try transformController.objectDataToConcreteObject(data, inputModel:inputModel, completion: { (model:ExampleBaseModel) in
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

        XCTAssertThrowsError(try transformController.objectDataToConcreteObject(data, completion: { (model:ExampleBaseModel) in
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
    
    //MARK: objectsDataToConcreteObjects
    
    func testObjectDataToConcreteObjects() {
        let transformController = TransformController()
        
        guard
            let path = NSBundle.mainBundle().pathForResource("exampleBaseModelResultsArray", ofType: "json"),
            let data = NSData(contentsOfFile: path) else {
                XCTFail("problem loading json")
                return
        }
        
        do {
            try transformController.objectsDataToConcreteObjects(data, completion: { (results:[ExampleBaseModel]) in
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
    
    func testObjectDataToConcreteObjectsCustomRootKey() {
        let transformController = TransformController()
        
        guard
            let path = NSBundle.mainBundle().pathForResource("exampleBaseModelResultsArrayCustomRootKey", ofType: "json"),
            let data = NSData(contentsOfFile: path) else {
                XCTFail("problem loading json")
                return
        }
        
        do {
            try transformController.objectsDataToConcreteObjects(data, rootKey:"items", completion: { (results:[ExampleBaseModel]) in
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
    
    func testObjectDataToConcreteObjectsFromSingleItem() {
        let transformController = TransformController()
        
        guard
            let path = NSBundle.mainBundle().pathForResource("exampleBaseModel", ofType: "json"),
            let data = NSData(contentsOfFile: path) else {
                XCTFail("problem loading json")
                return
        }
        
        do {
            try transformController.objectsDataToConcreteObjects(data, completion: { (results:[ExampleBaseModel]) in
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
        
        XCTAssertThrowsError(try transformController.objectsDataToConcreteObjects(data, completion: { (results:[ExampleBaseModel]) in
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

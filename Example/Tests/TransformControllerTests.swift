//
//  TransformControllerTests.swift
//  AirRivet
//
//  Created by Hans Van Herreweghe on 21/04/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import XCTest
@testable import AirRivet

class ExampleBaseModel: BaseModel {
    var objectId: String?
    var errorController: ErrorController
    
    required init(json: AnyObject) {
        errorController = ConcreteErrorController()
        importFromJSON(json)
    }
    
    static func getErrorController() -> ErrorController {
        return ConcreteErrorController()
    }
    
    static func contextPath() -> String {
        return "something"
    }
    
    static func serviceParameters() -> ServiceParameters {
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

class TransformControllerTests: XCTestCase {
    
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
            XCTAssertTrue(true)
        }
    }
}

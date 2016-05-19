//
//  TransformJSON.swift
//  AirRivet
//
//  Created by Stijn Willems on 07/04/16.
//  2016 iCapps. MIT Licensed.
//

import Foundation

public enum TransformType: String {
	case JSON = "json"
}

/**
Transformations of data to an initialized object(s). This implementation expects data to be valid JSON.
Any Type using these functions should be :

- `Parsable`
- `Mitigatable` -> Try to solve problems found in the data provided.

## Tasks

### TransformJSON data to `Rivetable` instances.

*/

public class TransformJSON {

	public init() {
	}

	/**
	- returns: A type of transformer. By default we tranform JSON. But you could provide another to transform any `NSData`.
	*/

	public func type () -> TransformType {
		return .JSON
	}

	//MARK: - TransformJSON data to `Rivetable` instances.

	/**
	On success returns an instance of type `Rivet` initialized with `data`.

	- parameter data: Valid JSON
    - parameter inputModel: Optional input object of `Type`. If no input object is provided, a new object of `Type` is created based on the JSON.
     If an existing object of `Type` is passed, the object properties are filled in based on the JSON.
	- returns: Via the completion block a parsed object of `Type` is returned.
	- throws: JSON errors that are not `Mitigatable`
	*/

	public func transform<Rivet: protocol<Parsable, Mitigatable>>(data: NSData, succeed:(Rivet)->()) throws {

		let mitigator = Rivet.responseMitigator()

		do {
			try mitigator.mitigate {
				let json =  try self.foundationObjectFromData(data, rootKey: nil, mitigator: mitigator)
				succeed(try Rivet(json:json, managedObjectContext: Rivet.managedObjectContext()))
			}

		}catch ResponseError.InvalidDictionary(dictionary: let dict) {
			if let correctedDictionary = try mitigator.invalidDictionary(dict) {
				succeed(try Rivet(json:correctedDictionary, managedObjectContext:  Rivet.managedObjectContext()))
			}else {
				throw ResponseError.InvalidDictionary(dictionary: dict)
			}
		}catch {
			throw error
		}
	}

	/**
	On success returns an array of type `Rivet` that are initialized with `data`.

	- parameter data: Valid JSON
    - parameter rootKey: Root of the array. Defaults to 'results', but can be overridden to a custom value
	- returns: Via the completion block an array of parsed objects of `Type`.
	- throws: JSON errors that are not `Mitigatable`
	*/

    public func transform<Rivet: protocol<Parsable, Mitigatable>>(data: NSData, succeed:([Rivet])->()) throws{

		let mitigator = Rivet.responseMitigator()
		try mitigator.mitigate {
			let json = try self.foundationObjectFromData(data, rootKey: Rivet.rootKey(), mitigator: mitigator)

			if let array = json as? [[String:AnyObject]] {
				succeed(try self.dictToArray(array))
			}else if let dict = json as? [String:AnyObject] {
				let model = try Rivet(json:dict, managedObjectContext: Rivet.managedObjectContext())
				print("\(model)")

				succeed([model])
			}else if let array = json as? [[String:AnyObject]] {
				succeed(try self.dictToArray(array))
			}
			else {
				throw ResponseError.InvalidDictionary(dictionary: json)
			}
		}
	}

	/**
	Create a Foundation object from data. This data can be JSON. The default implementation of the `TransformJSON` deals only with JSON data.
	- parameter: (optional) used to extract the needed data from the `blob` of data that you provide. In JSON this would be `{ "rootKey": "data to parse"}.`
	- parameter mitigator: will deal with invalid data errors or throw an error.
	- returns: A Foundation object that can be used while parsing
	*/

	public func foundationObjectFromData(data: NSData, rootKey: String?, mitigator: ResponseMitigatable) throws -> AnyObject {

		var json: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)

		if let
			rootKey = rootKey,
			jsonWithoutRoot = json[rootKey]{

			if jsonWithoutRoot == nil {
				if let correctedJson = try mitigator.invalidDictionary(json) {
					json = correctedJson
				}else {
					throw ResponseError.InvalidDictionary(dictionary: json)
				}

			}else {
				json = jsonWithoutRoot!
			}
		}

		return json
	}

	private func dictToArray<Rivet: Parsable>(array: [[String:AnyObject]]) throws -> [Rivet] {
		var concreteObjectArray = [Rivet]()
		for dict in array {
			let model = try Rivet(json:dict, managedObjectContext: Rivet.managedObjectContext())
			concreteObjectArray.append(model)
		}
		return concreteObjectArray
	}
}

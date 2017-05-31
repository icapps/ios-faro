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

public enum TransformJSONError: Error {
	case general
}

/**
Transformations of data to an initialized object(s). This implementation expects data to be valid JSON.
Any Type using these functions should be :

- `Parsable`
- `Mitigatable` -> Try to solve problems found in the data provided.

## Tasks

### TransformJSON data to `Rivetable` instances.

*/

open class TransformJSON {

	public init() {
	}

	/**
	- returns: A type of transformer. By default we tranform JSON. But you could provide another to transform any `NSData`.
	*/

	open func type () -> TransformType {
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

	open func transform<Rivet: Parsable & Mitigatable>(_ data: Data, succeed: @escaping (Rivet)->()) throws {

		let mitigator = Rivet.responseMitigator()

		do {
			try mitigator.mitigate {
				let json =  try self.foundationObjectFromData(data, rootKey: nil, mitigator: mitigator)

				if let entity = try Rivet.lookupExistingObjectFromJSON(json, managedObjectContext: Rivet.managedObjectContext()) {
					succeed(entity)
				}else {
					succeed(try Rivet(json:json, managedObjectContext: Rivet.managedObjectContext()))
				}
			}

		}catch ResponseError.invalidDictionary(dictionary: let dict) {
			if let correctedDictionary = try mitigator.invalidDictionary(dict) {
				succeed(try Rivet(json:correctedDictionary, managedObjectContext:  Rivet.managedObjectContext()))
			}else {
				throw ResponseError.invalidDictionary(dictionary: dict)
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

    open func transform<Rivet: Parsable & Mitigatable>(_ data: Data, succeed: @escaping ([Rivet])->()) throws{

		let mitigator = Rivet.responseMitigator()
		try mitigator.mitigate {
			let json = try self.foundationObjectFromData(data, rootKey: Rivet.rootKey(), mitigator: mitigator)

			if let array = json as? [[String:Any]] {
				succeed(try self.dictToArray(array))
			}else if let json = json as? [String:Any] {
				if let entity = try Rivet.lookupExistingObjectFromJSON(json, managedObjectContext: Rivet.managedObjectContext()) {
					succeed([entity])
				}else {
					succeed([try Rivet(json:json as Any, managedObjectContext: Rivet.managedObjectContext())])
				}
			}else if let array = json as? [[String:Any]] {
				succeed(try self.dictToArray(array))
			}
			else {
				throw ResponseError.invalidDictionary(dictionary: json)
			}
		}
	}

	/**
	Create a Foundation object from data. This data can be JSON. The default implementation of the `TransformJSON` deals only with JSON data.
	- parameter: (optional) used to extract the needed data from the `blob` of data that you provide. In JSON this would be `{ "rootKey": "data to parse"}.`
	- parameter mitigator: will deal with invalid data errors or throw an error.
	- returns: A Foundation object that can be used while parsing
	*/

	open func foundationObjectFromData(_ data: Data, rootKey: String?, mitigator: ResponseMitigatable) throws -> Any {
		let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

		if let rootKey = rootKey,
		   let json = json as? [String: Any],
		   let jsonWithoutRoot = json[rootKey] {

			return jsonWithoutRoot
		}

		return json
	}

	fileprivate func dictToArray<Rivet: Parsable>(_ array: [[String:Any]]) throws -> [Rivet] {
		var concreteObjectArray = [Rivet]()
		for json in array {

			if let entity = try Rivet.lookupExistingObjectFromJSON(json as Any, managedObjectContext: Rivet.managedObjectContext()) {
				concreteObjectArray.append(entity)
			}else {
				concreteObjectArray.append(try Rivet(json:json as Any, managedObjectContext: Rivet.managedObjectContext()))
			}
		}
		return concreteObjectArray
	}
}

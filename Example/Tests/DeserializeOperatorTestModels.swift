//
//  DeserializeOperatorTestModels.swift
//  Faro
//
//  Created by Stijn Willems on 24/01/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Faro
import Stella

// MARK: - Example Models

class IntegerLink: Deserializable, Updatable, Linkable, Hashable, CustomDebugStringConvertible, CustomStringConvertible {
	typealias ValueType = Int

	var uuid: Int

	// MARK: - Hashable

	var hashValue: Int {
		return uuid
	}

	static func == (lhs: IntegerLink, rhs: IntegerLink) -> Bool {
		return lhs.uuid == rhs.uuid
	}

	// MARK: - Linkable

	var link: (key: String, value: Int) { return (key: "uuid", value: uuid) }

	convenience init () {
		self.init(from: ["uuid": UUID().uuidString.hashValue])!
	}

	required init?(from raw: Any) {
		uuid = UUID().uuidString.hashValue
		do {
			try update(from: raw)
		} catch {
			print(error)
			return nil
		}

	}

	func update(from raw: Any) throws {
		guard let json = raw as? [String: Any] else {
			throw FaroDeserializableError.invalidJSON(model: self, json: raw)
		}

		try self.uuid |< json[.uuid]
	}

	// MARK: - Custom String Convertible

	var description: String {return "IntegerLinker id: \(uuid)"}
	var debugDescription: String { return description}
	
}

class Parent: Deserializable, Updatable, Linkable {
	typealias ValueType = String

	var uuid: String
	var relation: DeserializableObject
	var toMany = [DeserializableObject]()
	var setToMany = Set<DeserializableObject>()

	// MARK: - Linkable

	var link: (key: String, value: String) { return (key: "uuid", value: uuid) }

	required init?(from raw: Any) {
		// Temp values are required because swift needs initialization
		uuid = ""
		relation = DeserializableObject()
		do {
			try update(from: raw)
		} catch {
			print(error)
			return nil
		}
	}

	func update(from raw: Any) throws {
		guard let json = raw as? [String: Any] else {
			throw FaroDeserializableError.invalidJSON(model: self, json: raw)
		}
		try uuid |< json[.uuid]
		try relation |< json[.relation]
		do {
			try toMany |< json[.toMany]
			try setToMany |< json[.setToMany]
		} catch {
			printError(error)
		}
	}

}
class DeserializableObject: Deserializable, Updatable, Linkable, Hashable, CustomDebugStringConvertible, CustomStringConvertible {
	typealias ValueType = String

	var uuid: String
	var amount: Int?
	var price: Double?
	var tapped: Bool?
	var date: Date?

	var requiredDate: Date

	// MARK: - Hashable

	var hashValue: Int {
		return uuid.hashValue
	}

	static func == (lhs: DeserializableObject, rhs: DeserializableObject) -> Bool {
		return lhs.uuid == rhs.uuid
	}

	// MARK: - Linkable

	var link: (key: String, value: String) { return (key: "uuid", value: uuid) }

	convenience init () {
		self.init(from: ["uuid": UUID().uuidString])!
	}

	required init?(from raw: Any) {
		uuid = UUID().uuidString
		requiredDate = Date()
		do {
			try update(from: raw)
		} catch {
			print(error)
			return nil
		}

	}

	func update(from raw: Any) throws {
		guard let json = raw as? [String: Any] else {
			throw FaroDeserializableError.invalidJSON(model: self, json: raw)
		}

		try self.uuid |< json[.uuid]
		self.amount |< json[.amount]
		self.price |< json[.price]
		self.tapped |< json[.tapped]
		self.date |< (json[.date], "yyyy-MM-dd")
	}

	// MARK: - Custom String Convertible

	var description: String {return "DeserializableObject id: \(uuid) price: \(price)"}
	var debugDescription: String { return "DeserializableObject id: \(uuid) price: \(price), amount: \(amount), tapped: \(tapped), date: \(date)" }

}

// MARK: - Dictionary Helpers

enum API {

	enum Common: String {
		case uuid, amount, price, tapped, date
	}

	enum Relation: String {
		case toMany, setToMany, relation
	}
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

	subscript (map: API.Common) -> Value? {
		get {
			guard let key = map.rawValue as? Key else {
				return nil
			}

			let dict = self[key] as Value?
			return dict

		} set (newValue) {
			guard let newValue = newValue, let key = map.rawValue as? Key  else {
				return
			}

			self[key] = newValue
		}
	}

}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {

	subscript (map: API.Relation) -> Value? {
		get {
			guard let key = map.rawValue as? Key else {
				return nil
			}

			let dict = self[key] as Value?
			return dict

		} set (newValue) {
			guard let newValue = newValue, let key = map.rawValue as? Key  else {
				return
			}

			self[key] = newValue
		}
	}
	
}

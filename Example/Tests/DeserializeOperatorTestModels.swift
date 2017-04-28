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

class IntegerLink: JSONDeserializable, JSONUpdatable, Linkable, Hashable, CustomDebugStringConvertible, CustomStringConvertible {
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
		//swiftlint:disable force_try
		try! self.init(["uuid": UUID().uuidString.hashValue])
	}

	required init(_ raw: [String: Any]) throws {
		uuid = UUID().uuidString.hashValue
		try update(raw)
	}

	func update(_ raw: [String: Any]) throws {
		uuid = try create("uuid", from: raw)
	}

	// MARK: - Custom String Convertible

	var description: String {return "IntegerLinker id: \(uuid)"}
	var debugDescription: String { return description}

}

class Parent: JSONDeserializable, JSONUpdatable, Linkable {
	typealias ValueType = String

	var uuid: String
	var relation: DeserializableObject
	var toMany = [DeserializableObject]()
	var setToMany = Set<DeserializableObject>()

	// MARK: - Linkable

	var link: (key: String, value: String) { return (key: "uuid", value: uuid) }

	required init(_ raw: [String: Any]) throws {

		// Use the create functions before using self.

		uuid = try create("uuid", from: raw)
		relation = try create("relation", from: raw)

		// Self is now initionalized and you can update the rest.
		try update(raw)
	}

	func update(_ raw: [String: Any]) throws {
		try uuid |< raw[.uuid]
		try relation |< raw[.relation]
		do {
			try toMany |< raw[.toMany]
			try setToMany |< raw[.setToMany]
		} catch {
			printError(error)
		}
	}

}
class DeserializableObject: JSONDeserializable, JSONUpdatable, Linkable, Hashable, CustomDebugStringConvertible, CustomStringConvertible {
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
		//swiftlint:disable force_try
		try! self.init(["uuid": UUID().uuidString, "date": "1983-01-14"])
	}

	required init(_ raw: [String: Any]) throws {
		uuid = try create("uuid", from: raw)
		requiredDate = try create("date", from: raw, format: "yyyy-MM-dd")
		try update(raw)
	}

	func update(_ raw: [String: Any]) throws {
		try self.uuid |< raw[.uuid]

		self.date |< (raw[.date], "yyyy-MM-dd")

		self.amount |< raw[.amount]
		self.price |< raw[.price]
		self.tapped |< raw[.tapped]
	}

	// MARK: - Custom String Convertible

	var description: String {return "DeserializableObject id: \(uuid) price: \(String(describing: price))"}
	//swiftlint:disable line_length
	var debugDescription: String { return "DeserializableObject id: \(uuid) price: \(String(describing: price)), amount: \(String(describing: amount)), tapped: \(String(describing:tapped)), date: \(String(describing:date))" }

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

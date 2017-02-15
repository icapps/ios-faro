import Foundation

public enum FaroDeserializableError: Error {
	case intMissing(rhs: Int? , lhs: Any?)
	case doubleMissing(lhs: Double? , rhs: Any?)
	case stringMissing(lhs: String? , rhs: Any?)

	case deserializableMissing(lhs: Any?, rhs: Any?)

	case rawRepresentableMissing(lhs: Any?, rhs: Any?)
	case rawRepresentableMissingWithKey(key: String, json: Any?)
	case rawRepresentableWrongValue(key: String, value: Any?)

	case dateMissing(lhs: Date?, rhs: Any?)
	case dateMissingWithKey(key: String, json: [String: Any])

	case boolMissing(lhs: Bool?, rhs: Any?)

	case invalidDate(String)
	case invalidJSON(model: Any, json: Any)

	case linkNotUniqueInJSON([[String: Any]], linkValue: String)

	case emptyValue(key: String)

	case emptyKey
}

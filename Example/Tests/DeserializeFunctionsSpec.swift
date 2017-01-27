import Quick
import Nimble

import Faro
@testable import Faro_Example

enum RawInt: Int {
	case zero, one
}

enum RawString: String {
	case first, second
}

class DeserializeFunctionSpec: QuickSpec {

    override func spec() {
        describe("DeserializeFunctionSpec") {

			var o1: DeserializableObject!
			beforeEach {
				 o1 = DeserializableObject()
			}
			context("should parse form JSON") {

				context("Values") {

					it("Any value") {
						let uuidKey = "uuid"
						let json = [uuidKey: "some id" as Any]

						expect {
							o1.uuid = try parse(uuidKey, from: json)

							return expect(o1.uuid) == json["uuid"] as? String
						}.toNot(throwError())

					}

					context("RawRepresentable") {

						context("No throw") {

							it("Int") {
								expect {
									let foo: RawInt = try parse("rawInt", from: ["rawInt": 0])
									return expect(foo.rawValue) == RawInt.zero.rawValue
									}.toNot(throwError())
							}

							it("String") {
								expect {
									let foo: RawString = try parse("rawInt", from: ["rawInt": "first"])
									return expect(foo.rawValue) == RawString.first.rawValue
									}.toNot(throwError())
							}

						}

						context("Throw") {

							it("Int") {
								expect {
									let _: RawInt = try parse("rawInt", from: ["rawInt": 10])
									return false
								}.to(throwError())
							}

							it("String") {
								expect {
									let _: RawString = try parse("rawInt", from: ["rawInt": "unknown"])
									return false
								}.to(throwError())
							}
						}

					}

				}

				context ("Date") {

					it("has TimeInterval") {
						let dateKey = "date"
						let dateTimeInterval: TimeInterval = 12345.0
						let json = ["date": dateTimeInterval]

						expect {
							o1.date = try parse(dateKey, from: json, format:"")

							let date = Date(timeIntervalSince1970: json["date"]!)
							return expect(o1.date) == date
						}.toNot(throwError())

					}

					it("has String") {
						let dateKey = "date"
						let dateString = "1994-08-20"
						let json = [dateKey: dateString as Any]

						expect {
							o1.date = try parse(dateKey, from: json, format: "yyyy-MM-dd")

							return expect(o1.date).toNot(beNil())
						}.toNot(throwError())
					}

				}

				context("Object") {

					it("single") {
						let dict: [String: Any] = ["uuid": "some id"]
						let json: [String: Any] = ["node": dict]

						expect {
							let o1: DeserializableObject = try parse("node", from: json)

							return expect(o1.uuid) == "some id"
						}.toNot(throwError())

					}

					it("collection") {
						let dict1 = ["uuid": "id1"]
						let dict2 = ["uuid": "id2"]
						let json: [String: Any] = ["node": [dict1, dict2]]

						expect {
							let objectArray: [DeserializableObject] = try parse("node", from: json)

							expect(objectArray.count) == 2
							expect(objectArray.first?.uuid) == "id1"
							return expect(objectArray.last?.uuid) == "id2"
						}.toNot(throwError())

					}
				}

				context("RawRepresentable") {

					enum StringRaw: String {
						case foo, invalid
					}

					enum IntRaw: Int {
						case foo, invalid
					}

					context("String") {

						context("required") {

							it("set correct value") {
								var foo: StringRaw = StringRaw(rawValue: "invalid")!

								try? foo <-> "foo"

								expect(foo.rawValue) == StringRaw.foo.rawValue
							}

							it("throws for unknown") {
								var foo: StringRaw = StringRaw(rawValue: "invalid")!

								expect {return try foo <-> "bullshit"}.to(throwError {
									if let error = $0 as? FaroDeserializableError {
										switch error {
										case .rawRepresentableMissing(lhs: _, rhs: let string):
											expect(string as? String) == "bullshit"
										default:
											XCTFail("\(error)")
										}
									} else {
										XCTFail("\($0)")
									}
								})
							}
						}

						context("Optional") {

							it("set correct value") {
								var foo: StringRaw? = StringRaw(rawValue: "invalid")

								foo <-> "foo"

								expect(foo?.rawValue) == StringRaw.foo.rawValue
							}

							it("nil for unknown") {
								var foo: StringRaw? = StringRaw(rawValue: "invalid")

								foo <-> "bullshit"

								expect(foo).to(beNil())
							}
						}

					}

					context("Int") {

						context("required") {

							it("set value") {
								var foo: IntRaw = IntRaw(rawValue: IntRaw.invalid.rawValue)!

								try? foo <->  IntRaw.foo.rawValue

								expect(foo.rawValue) == IntRaw.foo.rawValue
							}

							it("throws for unknown") {
								var foo: StringRaw = StringRaw(rawValue: "invalid")!

								expect {return try foo <-> 1000}.to(throwError {
									if let error = $0 as? FaroDeserializableError {
										switch error {
										case .rawRepresentableMissing(lhs: _, rhs: let int):
											expect(int as? Int) == 1000
										default:
											XCTFail("\(error)")
										}
									} else {
										XCTFail("\($0)")
									}
								})
							}
						}

						context("Optional") {

							it("set value") {
								var foo: IntRaw? = IntRaw(rawValue: IntRaw.invalid.rawValue)

								foo <-> IntRaw.foo.rawValue

								expect(foo?.rawValue) == IntRaw.foo.rawValue
							}

							it("nil for unknown") {
								var foo: IntRaw? = IntRaw(rawValue: IntRaw.invalid.rawValue)

								foo <-> 100
								expect(foo).to(beNil())
							}

						}

					}

				}

			}

        }
    }

}

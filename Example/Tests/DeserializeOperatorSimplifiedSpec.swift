import Quick
import Nimble

import Faro
import Stella

class Foo: JSONDeserializable {
	var stringLink: DeserializableObject
	var integerLink = [IntegerLink]()

	convenience init() {
		//swiftlint:disable force_try
		try! self.init(["uuid": 259, "stringLink": ["uuid": "immutable model id", "date": "1983-01-14"]])
	}

	required init(_ raw: [String: Any]) throws {
		stringLink = try create("stringLink", from: raw)
	}

}

enum StringEnum: String {
	case first
	case second
}

class DeserializeOperatorSimplifiedSpec: QuickSpec {

	override func spec() {
		describe("IntegerLink operator") {

			it("links") {
				let foo = Foo()
				expect {
					try foo.integerLink |< [["uuid": 1]]
					try foo.stringLink |< ["uuid": "changed id"]

					expect(foo.integerLink.first?.uuid) == 1
					expect(foo.stringLink.uuid) == "changed id"

					return true
				}.toNot(throwError())
			}

			it("removes") {
				let foo = Foo()
				foo.integerLink = [IntegerLink(), IntegerLink(), IntegerLink()]

				try? foo.integerLink |< [[String: Any]]()

				expect(foo.integerLink.map {$0.uuid}) == []
			}
		}

	}

}

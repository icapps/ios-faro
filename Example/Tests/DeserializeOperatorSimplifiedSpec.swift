import Quick
import Nimble

import Faro
import Stella

class Foo: JSONDeserializable {
	var stringLink: DeserializableObject
	var integerLink = [IntegerLink]()

	convenience init() {
		//swiftlint:disable force_try
		try! self.init(["uuid": 259, "stringLink": ["uuid": "immutable model id"]])
	}

	required init(_ raw: [String: Any]) throws {
		stringLink = try create("stringlink", from: raw)
	}

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

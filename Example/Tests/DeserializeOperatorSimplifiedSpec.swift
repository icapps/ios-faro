import Quick
import Nimble

import Faro
import Stella

class Foo: Deserializable {
	var stringLink: DeserializableObject
	var integerLink = [IntegerLink]()

	convenience init() {
		self.init(from: ["uuid": 259, "stringLink": ["uuid": "immutable model id"]])!
	}

	required init?(from raw: Any) {
		stringLink = DeserializableObject()
		guard let json = raw as? [String: Any] else {
			return nil
		}

		do {
			try stringLink <-> json["stringLink"]
		} catch {
			printError(error)
		}
	}

}
class DeserializeOperatorSimplifiedSpec: QuickSpec {

	override func spec() {
		describe("IntegerLink operator") {

			it("links") {
				let foo = Foo()
				expect {
					try foo.integerLink <-> [["uuid": 1]]
					try foo.stringLink <-> ["uuid": "changed id"]

					expect(foo.integerLink.first?.uuid) == 1
					expect(foo.stringLink.uuid) == "changed id"

					return true
				}.toNot(throwError())
			}
		}
	}

}

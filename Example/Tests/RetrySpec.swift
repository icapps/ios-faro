import Foundation

import Quick
import Nimble

@testable import Faro
@testable import Faro_Example

class FaroSecureURLSessionSpec: QuickSpec {

	override func spec() {

		describe("Keep track of the retry count") {

            beforeEach {
                let backendConfiguration = BackendConfiguration(baseURL: "http://www.stub.com")
                let urlConfiguration = URLSessionConfiguration.default
                //: Because of the following line the URLSession will behave stubbed for paths that we stub. More below
                urlConfiguration.protocolClasses = [StubbedURLProtocol.self]

                FaroURLSession.setup(backendConfiguration: backendConfiguration, urlSessionConfiguration: urlConfiguration)
            }

            fit("implement retry tests") {
                let call = Call(path: "tests")
                let mockData = """
                {
                    "uuid" = "test mock"
                }   
                """.data(using: .utf8)!

                call.stub(statusCode: 401, data: nil)
                call.stub(statusCode: 200, data: mockData)

                FaroURLSession.shared().enableRetry(with: { (_, response, _) -> Bool in
                    return (response as? HTTPURLResponse)?.statusCode == 401
                })
                // Second call should not succeed
                let service = Service(call: call)

                waitUntil { done in
                    service.perform(MockModel.self) {
                        expect {try $0()}.to
                        done()
                    }
//                    service.perform(MockModel.self) { _ in
//                        XCTFail("second request should not success in case of a 401")
//                    }
                }

            }
        }

	}

}

import Quick
import Nimble

import Faro
@testable import Faro_Example

class PostDeserializableModelSpec: QuickSpec {

    override func spec() {
        describe("PostDeserializableModel") {

            context("Should parse") {
                it("from dictionary") {
                    let title = "some title"
                    let map: [Post.ServiceMap: Any] = [.id: 1, .title: title]
                    let post = Post(from: transform(map))

                    expect(post?.uuid) == 1
                    expect(post?.title) == title
                }
            }
        }
    }
    
}

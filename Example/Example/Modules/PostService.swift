//
//  PostService.swift
//  Faro_Example
//
//  Created by Stijn Willems on 03/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Faro

class PostService: Service {

    init() {
        super.init(call: Call(path: "posts"))
    }

}

class PostServiceHandler: ServiceHandler<Post> {

    init(completeArray: @escaping (() throws -> ([Post])) -> Void) {
        super.init(call: Call(path: "posts"), completeArray: completeArray)
    }
}

class PostServiceQueue: ServiceQueue {

    init(final: @escaping (Set<URLSessionTask>?) -> ()) {
        let session = FaroURLSession.shared()
        super.init(session: session, final: final)
    }

}

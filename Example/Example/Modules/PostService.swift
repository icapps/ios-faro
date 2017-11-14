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
        let session = FaroURLSession(backendConfiguration: BackendConfiguration(baseURL:  "http://jsonplaceholder.typicode.com"))
        super.init(call:  Call(path:"posts"), session: session)
    }

}

class PostServiceHandler: ServiceHandler<Post> {

    init(completeArray: @escaping (() throws -> ([Post])) -> Void) {
        let session = FaroURLSession(backendConfiguration: BackendConfiguration(baseURL:  "http://jsonplaceholder.typicode.com"))
        super.init(call:  Call(path:"posts"), session: session, completeArray: completeArray)
    }
}

class PostServiceQueue: ServiceQueue {

    init(final: @escaping (Set<URLSessionTask>?) -> ()) {
        let session = FaroURLSession(backendConfiguration: BackendConfiguration(baseURL: "http://jsonplaceholder.typicode.com"))
        super.init(session: session, final: final)
    }

}

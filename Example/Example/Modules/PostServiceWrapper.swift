//
//  PostServiceWrapper.swift
//  Faro_Example
//
//  Created by Stijn Willems on 15/01/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Faro

class PostServiceWrapper: Service {

    func wrappedPerform<M>(_ type: M.Type, complete: @escaping (M) -> Void) throws -> URLSessionTask where M : Decodable {

        let task = try perform(type) { (resultFunction) in
            let result: M = try resultFunction()
            complete(result)
        }
        return task
    }
}

//
//  StubURLSession.swift
//  Faro_Tests
//
//  Created by Stijn Willems on 03/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Faro

extension URLSessionConfiguration {

    open var protocolClasses: [AnyClass]? {
        get {
            return [StubbedURLProtocol.self]
        }
        set {
        }
    }
}

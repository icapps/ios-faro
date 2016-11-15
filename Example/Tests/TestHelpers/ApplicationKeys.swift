//
//  ApplicationKeys.swift
//  Faro
//
//  Created by Ben Algoet on 27/09/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import Stella

struct ApplicationKeys {

    static let sharedInstance = ApplicationKeys()

    var shouldMockServices: Bool {
        printBreadcrumb("Mocking all services")
        return true
    }

}

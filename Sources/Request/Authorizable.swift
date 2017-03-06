//
//  Authorizable.swift
//  Pods
//
//  Created by Stijn Willems on 06/03/2017.
//
//

import Foundation

public protocol Authenticatable {
	func authenticate(_ request: inout URLRequest)
}

//
//  Configuration.swift
//  Pods
//
//  Created by Stijn Willems on 31/08/16.
//
//

import Foundation

/// Use for different configurations for the specific environment you want to use for *Bar.*
public class Configuration {
    public let baseURL : String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }    
}
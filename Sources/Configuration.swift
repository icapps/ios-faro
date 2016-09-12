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
    public let baseURL: String

    /// For now we only support JSON. Can be Changed in the future
    public let adaptor: Adaptable
    public var url: NSURL? {
        get {
            return NSURL(string: baseURL)
        }
    }

    public init(baseURL: String, adaptor: Adaptable = JSONAdaptor()) {
        self.baseURL = baseURL
        self.adaptor = adaptor
    }
    
}
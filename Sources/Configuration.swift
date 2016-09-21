//
//  Configuration.swift
//  Pods
//
//  Created by Stijn Willems on 31/08/16.
//
//

import Foundation

/// Use for different configurations for the specific environment you want to use for *Bar.*
open class Configuration {
    open let baseURL: String

    /// For now we only support JSON. Can be Changed in the future
    open let adaptor: Adaptable
    open var url: URL? {
        get {
            return URL(string: baseURL)
        }
    }

    public init(baseURL: String, adaptor: Adaptable = JSONAdaptor()) {
        self.baseURL = baseURL
        self.adaptor = adaptor
    }
    
}

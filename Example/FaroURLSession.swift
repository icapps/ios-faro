
//
//  File.swift
//  
//
//  Created by Stijn Willems on 03/11/2017.
//

import Foundation

open class FaroURLSession {
    public let backendConfiguration: BackendConfiguration
    public let session: URLSession

    public init(backendConfiguration: BackendConfiguration, session: URLSession = URLSession.shared) {
        self.backendConfiguration = backendConfiguration
        self.session = session
    }

}

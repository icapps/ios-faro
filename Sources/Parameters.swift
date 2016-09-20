//
//  Parameters.swift
//  Pods
//
//  Created by Kris Boonefaes on 20/09/16.
//
//

public struct Parameters {
    public enum ParameterType {
        case httpHeader
        case jsonBody
        case urlComponents
    }
    
    public init(type: ParameterType!, parameters: [String: Any]!) {
        self.type = type
        self.parameters = parameters
    }
    
    public var type: ParameterType!
    public var parameters: [String: Any]!
}

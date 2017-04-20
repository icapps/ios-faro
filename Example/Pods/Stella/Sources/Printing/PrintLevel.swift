//
//  PrintLevel.swift
//  Pods
//
//  Created by Stijn Willems on 22/09/16.
//
//

import Foundation

public enum PrintLevel {
    case verbose
    case quiet
    case error
    case nothing
}

public struct Output {
    public static var level: PrintLevel = .quiet
}

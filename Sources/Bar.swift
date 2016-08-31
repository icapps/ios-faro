//
//  Bar.swift
//  Pods
//
//  Created by Stijn Willems on 31/08/16.
//
//

import Foundation


/// Serves anything you order.
public class Bar {
    public let configuration: Configuration
    public let service : JSONServeable

    public init (configuration: Configuration, service: JSONServeable = JSONService()) {
        self.configuration = configuration
        self.service = service
    }


}
//
//  Bar.swift
//  Pods
//
//  Created by Stijn Willems on 31/08/16.
//
//

import Foundation


/// Serves anything you order.

public class Bar <S: Serveable>  {

    public let configuration: Configuration
    public let service : S

    public init (configuration: Configuration, service: S) {

        self.configuration = configuration
        self.service = service
        
    }
    
}
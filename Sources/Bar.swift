//
//  Bar.swift
//  Pods
//
//  Created by Stijn Willems on 31/08/16.
//
//

import Foundation


/// Serves anything you order.

public class Bar <S: JSONServeable>  {
    public let configuration: Configuration
    public let service : S //TODO make this default to a JSON service and maybe not generic

    public init (configuration: Configuration, service: S) {
        self.configuration = configuration
        self.service = service
    }


}
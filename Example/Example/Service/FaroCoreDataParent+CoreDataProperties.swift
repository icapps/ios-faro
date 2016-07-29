//
//  FaroCoreDataParent+CoreDataProperties.swift
//  Faro
//
//  Created by Stijn Willems on 29/07/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import Faro

extension FaroCoreDataParent: UniqueAble {

    @NSManaged var uniqueValue: String?

}

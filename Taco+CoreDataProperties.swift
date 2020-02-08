//
//  Taco+CoreDataProperties.swift
//  TacoDemoIOS
//
//  Created by Jason Terhorst on 3/22/16.
//  Copyright © 2016 Jason Terhorst. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Taco {

    @NSManaged var calories: NSNumber?
    @NSManaged var details: String?
    @NSManaged var hasCheese: NSNumber?
    @NSManaged var hasLettuce: NSNumber?
    @NSManaged var layers: NSNumber?
    @NSManaged var meat: String?
    @NSManaged var name: String?
    @NSManaged var remoteId: String?

}

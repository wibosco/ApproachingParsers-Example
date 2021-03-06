//
//  User+CoreDataProperties.swift
//  ApproachingParsers
//
//  Created by Home on 16/04/2016.
//  Copyright © 2016 Boles. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var name: String?
    @NSManaged var userID: NSNumber?
    @NSManaged var profileURL: String?
    @NSManaged var reputation: NSNumber?
    @NSManaged var question: NSSet?

}

//
//  Question+CoreDataProperties.swift
//  ApproachingParsers
//
//  Created by William Boles on 14/04/2016.
//  Copyright © 2016 Boles. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Question {

    @NSManaged var index: NSNumber?
    @NSManaged var questionID: NSNumber?
    @NSManaged var title: String?
    @NSManaged var page: Page?
    @NSManaged var author: User?

}

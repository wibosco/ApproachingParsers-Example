//
//  UserParserValidator.swift
//  ApproachingParsers
//
//  Created by William Boles on 15/04/2016.
//  Copyright © 2016 Boles. All rights reserved.
//

import CoreData
import CoreDataServices

class UserParserValidator: Parser {

    //MARK: Accessors
    
    var userID: NSInteger?
    var name: String?
    var reputation: NSInteger?
    var profileURL: String?
    
    //MARK: Validate
    
    func validate(response: Dictionary<String, AnyObject>) -> Bool {
        guard let userID = response["user_id"] as? NSInteger,
            let name = response["display_name"] as? String,
            let reputation = response["reputation"] as? NSInteger,
            let profileURL = response["link"] as? String else {
                return false
        }

        self.userID = userID
        self.name = name
        self.reputation = reputation
        self.profileURL = profileURL
        
        /*---------------*/
        
        return true
    }
    
    //MARK: Parse

    func parseUser() -> User {
        let predicate = NSPredicate(format: "userID == \(self.userID!)")
        
        var user = self.localManagedObjectContext.retrieveFirstEntry(User.self, predicate: predicate) as? User
        
        if (user == nil) {
            user = NSEntityDescription.insertNewObjectForEntity(User.self, managedObjectContext: self.localManagedObjectContext) as? User
            
            user?.userID = self.userID
        }
        
        /*----------------*/
        
        user?.name = self.name
        user?.reputation = self.reputation
        user?.profileURL = self.profileURL
        
        /*----------------*/
        
        return user!
    }
}

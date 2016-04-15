//
//  QuestionsRetrievalOperation.swift
//  ApproachingParsers
//
//  Created by Home on 28/02/2016.
//  Copyright © 2016 Boles. All rights reserved.
//

import CoreData
import CoreDataServices

class QuestionsRetrievalOperationThrowsParser: NSOperation {
    
    //MARK: Accessors
    
    var feedID : NSManagedObjectID
    var data : NSData
    var refresh : Bool
    var completion : ((successful: Bool) -> (Void))?
    var callBackQueue : NSOperationQueue
    
    //MARK: Init
    
    init(feedID: NSManagedObjectID, data: NSData, refresh: Bool, completion: ((successful: Bool) -> Void)?) {
        self.feedID = feedID
        self.data = data
        self.refresh = refresh
        self.completion = completion
        self.callBackQueue = NSOperationQueue.currentQueue()!
        
        super.init()
    }
    
    //MARK: Main
    
    override func main() {
        super.main()
    
        do {
            let jsonResponse = try NSJSONSerialization.JSONObjectWithData(self.data, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<String, AnyObject>
            
            ServiceManager.sharedInstance.backgroundManagedObjectContext.performBlockAndWait({ () -> Void in
                
                do {
                    
                    let parser = QuestionParserThrows(managedObjectContext: ServiceManager.sharedInstance.backgroundManagedObjectContext)
                    let page = try parser.parseQuestions(jsonResponse)
                    
                    print("self.feedID: \(self.feedID)")
                    
                    let feed = try ServiceManager.sharedInstance.backgroundManagedObjectContext.existingObjectWithID(self.feedID) as! Feed
                    
                    let nextPageNumber = (feed.pages?.count)! + 1
                    
                    page.nextHref = "\(kStackOverflowQuestionsBaseURL)&page=\(nextPageNumber)"
                    page.index = self.indexOfNextPageToBeAdded(feed)
                    
                    self.reorderIndexes(feed)
                    
                    if (self.refresh) {
                        let fullPage = page.fullPage as! Bool
                        
                        feed.arePagesInSequence = !fullPage
                    }
                    
                    feed.addPage(page)
                    
                    /*----------------*/
                    
                    ServiceManager.sharedInstance.saveBackgroundManagedObjectContext()
                    
                    /*----------------*/
                    
                    if (self.completion != nil) {
                        self.completion!(successful: true)
                    }
                    
                } catch let error as NSError {
                    self.exitOperationWithFailure(error)
                }
            })
        } catch let error as NSError {
            self.exitOperationWithFailure(error)
        }
    }
    
    //MARK: Index
    
    func indexOfNextPageToBeAdded(feed: Feed) -> NSNumber {
        var indexOfNextPageToBeAdded: NSNumber
        
        if self.refresh {
            indexOfNextPageToBeAdded = -1
        } else {
            indexOfNextPageToBeAdded = feed.pages!.count
        }
        
        return indexOfNextPageToBeAdded
    }
    
    func reorderIndexes(feed: Feed) {
        let pages = feed.orderedPages()
        
        for index in (0..<pages.count) {
            let page = pages[index]
            page.index = index
        }
    }
    
    //MARK: Failure
    
    func exitOperationWithFailure(error: NSError) {
        print("Failed to parse: \(error.localizedDescription)")
        
        ServiceManager.sharedInstance.backgroundManagedObjectContext.rollback()
        
        self.callBackQueue.addOperationWithBlock({ () -> Void in
            if (self.completion != nil) {
                self.completion!(successful: false)
            }
        })

    }
}

//
//  KivaCart.swift
//  OAuthSwift
//
//  Created by john bateman on 11/8/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation
import CoreData

class KivaCart {
    
    // make the cart a Singleton
    static let sharedInstance = KivaCart()
    // usage:  KivaCart.sharedInstance
    
    // items in the cart
    var items = [KivaCartItem]()
    
    // return number of items in the cart
    var count: Int {
        return items.count
    }
    
    // designated initializer
    init() {
        print("KivaCart init called")
        
        // TODO: load all cart items here from the core data shared context
        fetchCartItems()
    }
    
    // designated initializer
    init(item: KivaCartItem) {
        self.items.append(item)
    }
    
    // designated initializer
    init(items: [KivaCartItem]) {
        self.items = items
    }
    
    // add an item to the cart
    func add(item: KivaCartItem) {
        items.append(item)
    }
    
    // remove all items from the cart
    func empty() {
        for item in items {
            self.removeItem(item)
        }
    }
    
    // remove an item from the cart
    func removeItem(item: KivaCartItem?) {
        if let item = item {
            if let index = items.indexOf(item) {
                removeItemByIndex(index)
            }
        }
    }
    
    // remove an item from the cart given it's index
    func removeItemByIndex(index: Int?) {
        
        if let index = index where index < items.count {
            
            let item = items[index]
            
            // remove the item from the core data store
            sharedContext.deleteObject(item)
            CoreDataStackManager.sharedInstance().saveContext()
            
            // remove the item from the array
            items.removeAtIndex(index)
        }
    }
    
    // get JSON representation of the cart.
    func getJSONData() -> NSData? {
        do {
            let serializableItems: [[String : AnyObject]] = convertCartItemsToSerializableItems()
            let json = try NSJSONSerialization.dataWithJSONObject(serializableItems, options: NSJSONWritingOptions.PrettyPrinted)
            return json
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    /*!
    @brief Convert the cart item to a Dictionary that is serializable by NSJSONSerialization.
    @discussion In order for NSJSONSerialization to convert an object to JSON the top level object must be an Array or Dictionary and all sub-objects must be one of the following types: NSString, NSNumber, NSArray, NSDictionary, or NSNull, or the Swift equivalents.
    */
    func convertCartItemsToSerializableItems() -> [[String : AnyObject]] {
        var itemsArray = [[String: AnyObject]]()
        for item in items {
            let dictionary: [String: AnyObject] = item.getDictionaryRespresentation()
            itemsArray.append(dictionary)
        }
        return itemsArray
    }
    
    /*!
    @brief Return a list of all the KivaLoan objects in the cart.
    */
    func getLoans() -> [KivaLoan]? {
        var loansInCart = [KivaLoan]()
        for item in self.items {
            if let loan = item.kivaloan {
                loansInCart.append(loan)
            }
        }
        return loansInCart
    }
    
    // MARK: - Fetched results controller
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: KivaCartItem.entityName)
        
        // Add a sort descriptor to enforce a sort order on the results.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "loanID", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()
    
    /* Perform a fetch of Loan objects to update the fetchedResultsController with the current data from the core data store. */
    func fetchCartItems() {
        var error: NSError? = nil
        
        dispatch_async(dispatch_get_main_queue()) {
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error1 as NSError {
                error = error1
                print("fetchCartItems error: \(error)")
            }
            self.items = self.fetchedResultsController.fetchedObjects as! [KivaCartItem]
        }
        
//        if let error = error {
//            LDAlert(viewController:self).displayErrorAlertView("Error retrieving loans", message: "Unresolved error in fetchedResultsController.performFetch \(error), \(error.userInfo)")
//        }
    }
    
    // Add an item to the local cart.
    func KivaAddItemToCart(loan: KivaLoan?, loanID: NSNumber?, donationAmount: NSNumber?, context: NSManagedObjectContext) {
        if let loan = loan {
            if let loanID = loanID {
                if let donationAmount = donationAmount {
                    let cart = KivaCart.sharedInstance
                    let item = KivaCartItem(loan: loan, loanID: loanID, donationAmount: donationAmount, context: context)
                    if !cart.items.contains(item) {
                        cart.add(item)
                        print("Added item to cart with loan Id: \(loanID) in amount: \(donationAmount)")
                        
                        // Persist the KivaCartItem object we added to the Core Data shared context
                        dispatch_async(dispatch_get_main_queue()) {
                            CoreDataStackManager.sharedInstance().saveContext()
                        }
                        
                    } else {
                        print("Item not added to cart. The cart already contains loanId: \(loanID)")
                    }
                    print("cart = \(cart.count) [KivaAddItemToCart]")
                }
            }
        }
    }
}
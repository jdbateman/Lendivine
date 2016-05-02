//
//  KivaCart.swift
//  OAuthSwift
//
//  Created by john bateman on 11/8/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This class provides methods to manage a cart of items that can be purchased on the Kiva service.

import Foundation
import CoreData

class KivaCart {
    
    // make the cart a Singleton
    static let sharedInstance = KivaCart()  // usage:  KivaCart.sharedInstance
    
    // items in the cart
    var items = [KivaCartItem]()
    
    // return number of items in the cart
    var count: Int {
        return items.count
    }
    
    // designated initializer
    init() {
        print("KivaCart init called")
        
        // load all cart items from the core data shared context
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
    
    // update the cart
    func update() {
        fetchCartItems()
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
            print("saveContext: KivaCart.removeItemByIndex()")
            CoreDataStackManager.sharedInstance().saveContext()
            
            // remove the item from the array
            items.removeAtIndex(index)
        }
    }
    
    func containsLoanId(id:NSNumber) -> Bool {
        for item in items {
            if item.loanID == id {
                return true
            }
        }
        return false
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
        @brief return an array of KivaLoan objects representing each loan ID stored in the cart.
        @discussion Loans are contructed from the main core data context.
    */
    func getLoans2() -> [KivaLoan]? {

        var loansInCart = [KivaLoan]()
    
        for item in self.items {
    
            var id:NSNumber = 0
            if let loanID = item.loanID {
                id = loanID
            }
            // NOTE: The context passed to createKivaLoanFromLoanID used to be ignored by fetchLoanByID2, which just used the shared context, but it now uses the passed context. this may modify the behvior of the app.
            if let loan:KivaLoan = KivaLoan.createKivaLoanFromLoanID(id, context: sharedContext /* CoreDataStackManager.sharedInstance().scratchContext*/) {
                loansInCart.append(loan)
            }
        }
        NSLog("loans in Cart: %@", loansInCart)
        return loansInCart
    }

    
    // MARK: - Fetched results controller
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        // todo - return CoreDataStackManager.sharedInstance().scratchContext
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
    }
    
    /*! 
        @brief Add a loan to the local cart.
        @discussion The function fails if a loan with the same id is already in the cart.
        @param (in) loan - The loan to add to the cart.
        @param (in) donationAmount - The dollar amount to donate towards the loan.
        @param (in) context - Core Data context.
        @return true if loan was successfully added to the cart, else false.
    */
    func KivaAddItemToCart(loan: KivaLoan?, /*loanID: NSNumber?,*/ donationAmount: NSNumber?, context: NSManagedObjectContext) -> Bool {
        
        print("KivaAddItemToCart called for loan \(loan?.name) & \(loan?.id)")
        
        if let loan = loan {

                if let donationAmount = donationAmount {
                    
                    let cart = KivaCart.sharedInstance
                    
                    // check if loan id is already in the cart
                    if let id = loan.id where cart.containsLoanId(id) {
                        return false
                    }
                    
                    // TODO: cart context - all calls to KivaAddItemToCart use sharedContext
                    let item = KivaCartItem(loan: loan /*loanID: loanID*/, donationAmount: donationAmount, context: context)
                    if !itemInCart(item) /*!cart.items.contains(item)*/ {
                        cart.add(item)
                        print("Added item to cart with loan Id: \(loan.id) in amount: \(donationAmount)")
                        
                        // Persist the KivaCartItem object we added to the Core Data shared context
// TODO - looks like we don't need this call here. Instead, persist from the viewcontroller where add to cart button was selected. TODO - go review them.
//                        dispatch_async(dispatch_get_main_queue()) {
//                            print("saveContext: KivaCart.KivaAddItemToCart()")
//                            CoreDataStackManager.sharedInstance().saveContext()
//                        }
                        return true
                        
                    } else {
                        print("Item not added to cart. The cart already contains loanId: \(loan.id)")
                        return false
                    }
                }
        }
        return false
    }
    
    /*! 
        @brief Determine if the specified item is in the cart.
        @discussion Comparison is done by the loanID property. Two items are considered Equatable if their loanID properties match.
        @param (in) item - The item to find in the cart.
        @return true if item is in the cart, else false if it is not in the cart.
    */
    func itemInCart(item:KivaCartItem) -> Bool {
        
        for nextItem in self.items {
            if item == nextItem {
                return true
            }
        }
        return false
    }
}
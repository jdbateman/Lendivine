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
import UIKit

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
        
        // load all cart items from the core data cart context
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
    func update(completion: () -> Void)  {
        dispatch_async(dispatch_get_main_queue()) {
            self.fetchCartItems()
            completion()
        }
    }
    
    // add an item to the cart
    func add(item: KivaCartItem) {
        items.append(item)
        CoreDataContext.sharedInstance().saveCartContext()
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
            CoreDataContext.sharedInstance().cartContext.deleteObject(item)
            CoreDataContext.sharedInstance().saveCartContext()
            
            // remove the item from the array
            items.removeAtIndex(index)
        }
    }
    
    func containsLoanId(id:NSNumber) -> Bool {
        for item in items {
            if item.id == id {
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
        @discussion Loans are contructed from the Cart context.
    */
    func getLoans2() -> [KivaLoan]? {

        var loansInCart = [KivaLoan]()
    
        for item in self.items {
    
            // NOTE: The context passed to createKivaLoanFromLoanID used to be ignored by fetchLoanByID2, which just used the shared context, but it now uses the passed context. this may modify the behvior of the app.
            if let loan:KivaLoan = KivaLoan(fromCartItem: item, context: CoreDataContext.sharedInstance().cartContext) {
                loansInCart.append(loan)
            }
        }
        NSLog("loans in Cart: %@", loansInCart)
        return loansInCart
    }

    
    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: KivaCartItem.entityName)
        
        // Add a sort descriptor to enforce a sort order on the results.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataContext.sharedInstance().cartContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()
    
    /* 
        @brief Perform a fetch of Loan objects to update the fetchedResultsController with the current data from the core data store.
        @discussion Caller must make this call on the main thread.
    */
    func fetchCartItems() {
        var error: NSError? = nil
        
//        dispatch_async(dispatch_get_main_queue()) {
            do {
                try self.fetchedResultsController.performFetch()
            } catch let error1 as NSError {
                error = error1
                print("fetchCartItems error: \(error)")
            }
            self.items = self.fetchedResultsController.fetchedObjects as! [KivaCartItem]
//        }
    }
    
    /*! 
        @brief Add a loan to the local cart.
        @discussion The function fails if a loan with the same id is already in the cart. The loan is not persisted to the specified context. Rather, a new KivaCartItem is created in the Cart Context and the loan properties are copied to the KivaCartItem instance.
        @note It is the responsibility of the caller to save the cart item to the cartContext (if desired).
        @param (in) loan - The loan to add to the cart. Loan properties are read from the loan and set on the new KivaCartItem.
        @param (in) donationAmount - The dollar amount to donate towards the loan.
        @param (in) context - Core Data context in which the KivaCartItem is created.
        @return true if loan was successfully added to the cart, else false.
    */
    func KivaAddItemToCart(loan: KivaLoan?, donationAmount: NSNumber?, context: NSManagedObjectContext) -> Bool {
        
        if let loan = loan {

                if let donationAmount = donationAmount {
                    
                    let cart = KivaCart.sharedInstance
                    
                    // check if loan id is already in the cart
                    if let id = loan.id where cart.containsLoanId(id) {
                        return false
                    }
                    
                    let item = KivaCartItem(loan: loan, donationAmount: donationAmount, context: context)
                    
                    if !itemInCart(item) {
                        
                        cart.add(item)
                        
                        // Persist the loan to which the cart item refers.
                        CoreDataLoanHelper.upsert(loan, toContext: CoreDataContext.sharedInstance().cartContext) // TODO beware this might create cart duplicates. may need to use scratch context here to only persist a copy of the single loan.
                        
                         return true
                        
                    } else {
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
    
    /*! Update the badge on the Cart item in the tab bar to indicate the current number of items in the cart. */
    class func updateCartBadge(controller:UIViewController?) {
        
        guard let controller = controller else {return}
        
        let tabBarIndexOfCart = 2
        let tabArray = controller.tabBarController?.tabBar.items as NSArray!
        let tabItem = tabArray.objectAtIndex(tabBarIndexOfCart) as! UITabBarItem
        
        let cart = KivaCart.sharedInstance
        let count = cart.count
        if count > 0 {
            tabItem.badgeValue = String(count)
        } else {
            tabItem.badgeValue = nil
        }
    }
}
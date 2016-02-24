//
//  KivaCart.swift
//  OAuthSwift
//
//  Created by john bateman on 11/8/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation

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
        items.removeAll()
    }
    
    // remove an item from the cart
    func removeItem(item: KivaCartItem?) {
        if let item = item {
            if let index = items.indexOf(item) {
                items.removeAtIndex(index)
            }
        }
    }
    
    // remove an item from the cart given it's index
    func removeItemByIndex(index: Int?) {
        if let index = index {
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
    
}
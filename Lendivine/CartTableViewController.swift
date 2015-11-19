//
//  CartTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/15/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// This table view controller displays a set of loans retrieved from Kiva.org. TODO: Additional loans are displayed when the refresh button is selected. 

// TODO - support selecting a loan to display detailed information on the loan

import UIKit

class CartTableViewController: UITableViewController {

    var cart = KivaCart.sharedInstance
    var kivaAPI: KivaAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.kivaAPI = KivaAPI.sharedInstance
        
        let checkoutButton = UIBarButtonItem(image: UIImage(named: "Checkout-50"), style: .Plain, target: self, action: "onCheckoutButtonTapped")
        self.navigationItem.rightBarButtonItem = checkoutButton
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        print("cart = \(cart.items.count) [viewDidLoad]")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cart.items.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CartTableCellID", forIndexPath: indexPath) as! CartTableViewCell

        // Configure the cell...
        configureCell(cell, row: indexPath.row)
        
        return cell
    }

    func configureCell(cell: CartTableViewCell, row: Int) {
        let cartItem = cart.items[row]
        let loan = cartItem.loan as KivaLoan
        
        // make delete button corners rounded
        cell.changeDonationButton.layer.cornerRadius = 7
        cell.changeDonationButton.layer.masksToBounds = true
        
        cell.nameLabel.text = loan.name
        cell.sectorLabel.text = loan.sector
        cell.amountLabel.text = "$" + loan.loanAmount.stringValue
        cell.countryLabel.text = loan.country
        
        // donation amount
        let donationAmount = "$" + cartItem.donationAmount.stringValue
        
        // Set button image to donation amount
//        let donationImage: UIImage = textToImage("$25", inImage: UIImage(named:"EmptyCart-50")!, atPoint: CGPointMake(14, 8))
        let donationImage: UIImage = ViewUtility.createImageFromText(donationAmount, backingImage: UIImage(named:"EmptyCart-50")!, atPoint: CGPointMake(CGFloat(14), 4))
        cell.changeDonationButton.imageView!.image = donationImage
        
        // Set main image placeholder image
        cell.loanImageView.image = UIImage(named: "Add Shopping Cart-50") // TODO: update placeholder image in .xcassets
        
        // getKivaImage can retrieve the image from the server in a background thread. Make sure to update UI from main thread.
        loan.getImage() {success, error, image in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.loanImageView!.image = image
                }
            } else  {
                print("error retrieving image: \(error)")
            }
        }
        
        print("cart = \(cart.items.count) [configureCell]")
    }
    
    // Conditional editing of the table view. (Return true to allow edit of the item, false if item is not editable.)
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
/*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // Remove the data from collection and update the tableview.
            cart.removeItemByIndex(indexPath.row)
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
*/
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            cart.removeItemByIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func onCheckoutButtonTapped() {
        print("TODO: call KivaAPI.checkout")
        showEmbeddedBrowser()
    }
    
    /* Display url in an embeded webkit browser. */
    func showEmbeddedBrowser() {
        let controller = KivaCartViewController()
        //        var storyboard = UIStoryboard (name: "Main", bundle: nil)
        //        var controller = storyboard.instantiateViewControllerWithIdentifier("WebSearchStoryboardID") as! WebSearchViewController
        //controller.initialURL = url
        if let kivaAPI = self.kivaAPI {
            controller.request = kivaAPI.getKivaCartRequest()  // KivaCheckout()
        }
        //controller.webViewDelegate = self
        self.presentViewController(controller, animated: true, completion: nil);
    }

}

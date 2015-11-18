//
//  MyLoansTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/17/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// This table view controller displays a list of the loans made previously by the user.

import UIKit

class MyLoansTableViewController: UITableViewController {

    var kivaAPI: KivaAPI = KivaAPI.sharedInstance
    
    // a collection of the Kiva loans the user has made
    var loans = [KivaLoan]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize user's loans
        populateLoans()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        // #warning Incomplete implementation, return the number of rows
        return self.loans.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> MyLoansTableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MyLoansTableViewCellID", forIndexPath: indexPath) as! MyLoansTableViewCell

        // Configure the cell...
        configureCell(cell, row: indexPath.row)

        return cell
    }
    
    // Initialize the contents of the cell.
    func configureCell(cell: MyLoansTableViewCell, row: Int) {

        let loan = self.loans[row]
        cell.nameLabel.text = loan.name
        cell.sectorLabel.text = loan.sector
        cell.amountLabel.text = "$" + loan.loanAmount.stringValue
        cell.countryLabel.text = loan.country
        
        // Set placeholder image
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
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // Call the kiva API to initialize the local collection of loans previously made by the user.
    func populateLoans() {
        kivaAPI.kivaOAuthGetUserLoans() { success, error, loans in
            if success {
                if let loans = loans {
                    self.loans = loans
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                } else {
                    self.loans.removeAll()
                }
            } else {
                print("error retrieving user's loans from Kiva.org: \(error)")
            }
        }
    }
}

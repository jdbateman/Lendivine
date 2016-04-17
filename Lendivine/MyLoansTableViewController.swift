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
        
        configureBarButtonItems()
        
        navigationItem.title = "My Loans"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*! Setup the nav bar button items. */
    func configureBarButtonItems() {
        
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .Plain, target: self, action: "onMapButton")
        navigationItem.setRightBarButtonItem(mapButton, animated: true)
    }
    
    // MARK: Actions
    
    func onMapButton() {
        presentMapController()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        var amountString = "$"
        if let loanAmount = loan.loanAmount {
            amountString.appendContentsOf(loanAmount.stringValue)
        } else {
            amountString.appendContentsOf("0")
        }
        cell.amountLabel.text = amountString
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
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowMyLoansDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destinationViewController as! LoanDetailViewController
                let loan = self.loans[indexPath.row]
                controller.loan = loan
            }
            
        } else if segue.identifier == "MyLoansToMapSegueId" {
            
            //navigationItem.title = "MyLoans"
            let controller = segue.destinationViewController as! MapViewController
            controller.sourceViewController = self
            controller.navigationItem.title = "MyLoans"
            controller.loans = loans
            controller.showRefreshButton = false
        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentMapController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("MyLoansToMapSegueId", sender: self)
        }
    }
}

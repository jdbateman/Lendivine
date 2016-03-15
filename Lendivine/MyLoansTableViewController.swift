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
}

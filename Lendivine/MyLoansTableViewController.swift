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

    var noDataLabel: UILabel?
    
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*! Setup the nav bar button items. */
    func configureBarButtonItems() {
        
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .plain, target: self, action: #selector(MyLoansTableViewController.onMapButton))
        navigationItem.setRightBarButton(mapButton, animated: true)
    }
    
    // MARK: Actions
    
    func onMapButton() {
        presentMapController()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if loans.count > 0 {
            
            noDataLabel?.text = ""
            noDataLabel?.isHidden = true
            
            return 1
            
        } else {
            
            noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            
            if let noDataLabel = noDataLabel {
                noDataLabel.isHidden = false
                noDataLabel.text = "This account currently contains no loans."
                noDataLabel.textColor = UIColor.darkGray
                noDataLabel.textAlignment = .center
                tableView.backgroundView = noDataLabel
                tableView.separatorStyle = .none
            }
            
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.loans.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MyLoansTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyLoansTableViewCellID", for: indexPath) as! MyLoansTableViewCell

        // Configure the cell...
        configureCell(cell, row: indexPath.row)

        return cell
    }
    
    // Initialize the contents of the cell.
    func configureCell(_ cell: MyLoansTableViewCell, row: Int) {

        let loan = self.loans[row]
        cell.nameLabel.text = loan.name
        cell.sectorLabel.text = loan.sector
        var amountString = "$"
        if let loanAmount = loan.loanAmount {
            amountString.append(loanAmount.stringValue)
        } else {
            amountString.append("0")
        }
        cell.amountLabel.text = amountString
        cell.countryLabel.text = loan.country
        
        // Set placeholder image
        cell.loanImageView.image = UIImage(named: "Download-50")
        
        // getImage can retrieve the image from the server in a background thread. Make sure to update UI from main thread.
        loan.getImage(200, height:200, square:true) {
            success, error, image in
            if success {
                DispatchQueue.main.async {
                    cell.loanImageView!.image = image
                    
                    // draw border around image
                    cell.loanImageView!.layer.borderColor = UIColor.blue.cgColor;
                    cell.loanImageView!.layer.borderWidth = 2.5
                    cell.loanImageView!.layer.cornerRadius = 3.0
                    cell.loanImageView!.clipsToBounds = true
                }
            } else  {
                print("error retrieving image: \(error)")
            }
        }
    }

    // Call the kiva API to initialize the local collection of loans previously made by the user.
    // TODO: in future save the nextPage parameter returned by this call and implement paging to support users who have made many loans.
    var page:Int = 0
    func populateLoans() {
        kivaAPI.kivaOAuthGetUserLoans(page as NSNumber?) {
            success, error, loans, nextPage in
            if success {
                if let loans = loans {
                    self.loans = loans
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    self.loans.removeAll()
                }
            } else {
                if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.contains("offline"))! {
                    LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
                }
                print("error retrieving user's loans from Kiva.org: \(error)")
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowMyLoansDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destination as! LoanDetailViewController
                let loan = self.loans[indexPath.row]
                controller.loan = loan
                controller.showAddToCart = false
                controller.showBalanceInfo = true
            }
            
        } else if segue.identifier == "MyLoansToMapSegueId" {
            
            //navigationItem.title = "MyLoans"
            let controller = segue.destination as! MapViewController
            controller.sourceViewController = self
            controller.navigationItem.title = "MyLoans"
            controller.loans = loans
            controller.showRefreshButton = false
        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentMapController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "MyLoansToMapSegueId", sender: self)
        }
    }
}

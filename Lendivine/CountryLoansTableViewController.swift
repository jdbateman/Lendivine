//
//  CountryLoansTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/13/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This table view controller displays a list of current loans available in a particular country as returned in a response to a country specific search against the Kiva REST API. The loans are not persisted.

import UIKit
import CoreData

class CountryLoansTableViewController: UITableViewController {
    
    var country: Country?
    
    // var kivaAPI: KivaAPI = KivaAPI.sharedInstance
    
    var nextPageOfKivaSearchResults = 1
    
    // a collection of the Kiva loans the user has made
    var loans = [KivaLoan]()
    
    let activityIndicator = DVNActivityIndicator()
    
    // Set to true if No Results message should be displayed.
    var showNoResults: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.startActivityIndicator(tableView)
        
        nextPageOfKivaSearchResults = 1
        
        // initialize user's loans
        refreshLoans(nil)
        
        configureView()
        
        // add the map bar button item
        let mapButton = UIBarButtonItem(image: UIImage(named: "earth-america-7"), style: .plain, target: self, action: #selector(CountryLoansTableViewController.onMapButton))
        navigationItem.setRightBarButton(mapButton, animated: true)
        self.navigationItem.rightBarButtonItems?.first?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureView()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        navigationItem.title = loans.first?.country
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if self.loans.count > 0 {
            
            if let countryName = self.country?.name {
                navigationItem.title = String(format:"\(self.loans.count) in %@", countryName)
            }
            
            self.tableView.backgroundView = nil
            return 1
            
        } else {
            
            if self.showNoResults {
                
                let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text = "No loans available"
                if let country = self.country, let name = country.name {
                    noDataLabel.text = "No loans available" + " for " + "\(name)"
                }
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
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CountryLoanTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryLoansTableViewCellID" /*"MyLoansTableViewCellID"*/, for: indexPath) as! CountryLoanTableViewCell //MyLoansTableViewCell
        
        // Configure the cell...
        configureCell(cell, row: indexPath.row)
        
        cell.parentTableView = tableView
        cell.parentController = self
        
        return cell
    }
    
    // Initialize the contents of the cell.
    func configureCell(_ cell: CountryLoanTableViewCell /*MyLoansTableViewCell*/, row: Int) {
        
        cell.controller = self
        
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
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.center = CGPoint(x: cell.loanImageView.center.x - 8, y: cell.loanImageView.center.y - 20)
        cell.loanImageView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // getImage can retrieve the image from the server in a background thread. Make sure to update UI from main thread.
        loan.getImage() {success, error, image in
            
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
            }
            
            if success {
                DispatchQueue.main.async {
                    cell.loanImageView!.image = image
                }
            } else  {
                print("error retrieving image: \(error)")
            }
        }
        
        cell.addToCartButton.layer.cornerRadius = 19.2 // 24
        if let cart = UIImage(named: "Add Shopping Cart-50") {
            let tintedCart = cart.withRenderingMode(.alwaysTemplate)
            cell.addToCartButton.imageView!.image = tintedCart
            cell.addToCartButton.imageView!.tintColor = UIColor.blue
        }
    }
    
    
    // MARK: Actions
    
    func onMapButton() {
        presentMapController()
    }
    
    @IBAction func onSeeMoreLoansButton(_ sender: AnyObject) {

        refreshLoans() {
            success, error in
            if success {
                self.tableView.reloadData()
            } else {
                print("refreshLoans returned an error: \(error)")
            }
        }
    }
    
    // MARK: UITableViewDelegate Accessory Views
    
    /*! Disclosure indicator tapped. Present the loan detail view controller for the selected loan. */
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        guard indexPath.row < loans.count else {return}
        
        let loan = loans[indexPath.row]
        self.presentLoanDetailViewController(loan)
    }
    
    
    // MARK: Navigation
    
    /* Modally present the LoanDetail view controller. */
    func presentLoanDetailViewController(_ loan: KivaLoan?) {
        guard let loan = loan else {
            return
        }
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoanDetailStoryboardID") as! LoanDetailViewController
        controller.loan = loan
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowCountryLoanDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destination as! LoanDetailViewController
                
                let loan = self.loans[indexPath.row]
                controller.loan = loan
            }
            
        } else if segue.identifier == "CountryLoanToMapSegueId" {
            
            // navigationItem.title = loans.first?.country
            
            let controller = segue.destination as! MapViewController
            
            controller.sourceViewController = self
            
            controller.navigationItem.title = loans.first?.country
            
            // get list of loans displayed in this view controller
            controller.loans = loans
        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentMapController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "CountryLoanToMapSegueId", sender: self)
        }
    }

    
    // MARK: Kiva API

    func refreshLoans(_ completionHandler: ((_ success: Bool, _ error: NSError?) -> Void)? ) {
        
        guard nextPageOfKivaSearchResults != -1 else {
            showNoMoreResultsAlert()
            return
        }
        
        // Search Kiva.org for the next page of Loan results.
        CountryLoansKivaApiHelper.populateLoansForCountry(LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE, twoLetterCountryCode: self.country?.countryCodeTwoLetter, nextPage: self.nextPageOfKivaSearchResults) {
            success, error, loans, nextPage in
            
            if success {
                
                // enable/disable earth bar button item
                if let loans = loans, loans.count > 0 {
                    self.navigationItem.rightBarButtonItems?.first?.isEnabled = true
                } else {
                    self.navigationItem.rightBarButtonItems?.first?.isEnabled = false
                }
                
                // Append any new loans returned by the Kiva api to our existing collection.
                if let loans = loans {
                    self.loans.append(contentsOf: loans)
                }
                
                // save the nextPage
                self.nextPageOfKivaSearchResults = nextPage
                
                DispatchQueue.main.async {

                    self.tableView.reloadData()
                    
                    if self.loans.count == 0 {
                        self.showNoResults = true
                    }
                    
                    if let completionHandler = completionHandler {
                        completionHandler(true, nil)
                    }
                }
                
            } else {
                
                self.showNoResults = true
                
                print("failed to populate loans. error: \(error?.localizedDescription)")
                
                
                if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.contains("offline"))! {
                    LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
                }
                
                if let completionHandler = completionHandler {
                    completionHandler(false, error)
                }
            }
            
            self.activityIndicator.stopActivityIndicator()
        }
    }
    
    
    // MARK: Core Data
    
    /*
    @brief Perform a fetch of all the loan objects in the countryLoan context. Return array of KivaLoan instances, or an empty array if no results or query failed.
    @discussion Updates the fetchedResultsController with the matching data from the core data store.
    */
    func fetchAllLoans() -> [KivaLoan]? {
        
        let error: NSErrorPointer? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: KivaLoan.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        var results: [AnyObject]?
        do {
            results = try CoreDataContext.sharedInstance().countryLoanContext.fetch(fetchRequest) as? [KivaLoan]
        } catch let error1 as NSError {
            error??.pointee = error1
            print("Error in fetchAllLoans(): \(error)")
            return nil
        }
        
        // Check for Errors
        if error != nil {
            print("Error in fetchAllLoans(): \(error)")
        }
        
        return results as? [KivaLoan] ?? [KivaLoan]()
    }
    
    // MARK: Helper
    func showNoMoreResultsAlert() {
        
        let title = "No More Loans"
        var message = "No additional loans are available"
        if let countryName = self.country?.name {
            message = "No additional loans are available in \(countryName)."
        }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            // handle OK pressed in alert controller
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}


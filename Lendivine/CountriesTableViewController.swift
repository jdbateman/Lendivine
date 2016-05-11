//
//  CountriesTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/10/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This table view controller displays a list of countries queried from the RESTCountries REST API.

import UIKit
import CoreData

let restCountriesAPI = RESTCountries.sharedInstance()

class CountriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)

    var countries = [Country]()
    var filteredTableData = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCountriesFromCoreData()
        
        setupView()
        
        addSearchBar()
        
        navigationItem.title = "Countries"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to countries from RESTCountries web service.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CountriesTableViewController.onCountriesUpdate), name: countriesUpdateNotificationKey, object: nil)
        
        setupView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observer for the countries update notification.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupView() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        updateMapSearchItem()
    }
    
    func mapAction(sender:UIButton!)
    {
        // Modally present the MapViewController on the main thread.
        dispatch_async(dispatch_get_main_queue()) {
            
            self.navigationController?.setNavigationBarHidden(false, animated: false)

            self.performSegueWithIdentifier("CountriesToMapSegueId", sender: self)
        }
    }
    
    /*! hide the status bar */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /*! Initialize countries collection from core data using a scratch context. */
    func initCountriesFromCoreData() {
        
        DVNCountries.sharedInstance().fetchCountries()
        
        // set the NSFetchedResultsControllerDelegate
        DVNCountries.sharedInstance().fetchedResultsController.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK - Search Results Controller
    
    func addSearchBar() {
        
        // Prevents the search display controller from hanging around when a search result cell is selected and a new view controller is pushed.
        self.definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeThatFits(CGSize(width: 80, height: 20))    // sizeToFit()
        searchController.searchBar.barTintColor = UIColor(rgb:0xFFE8A1)
        
        self.tableView.tableHeaderView = searchController.searchBar
        
        //todo searchController.searchBar.delegate = self
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        if filteredTableData.count > 0 {
            filteredTableData.removeAll(keepCapacity: false)
        } else {
            updateMapSearchItem()
        }
        
        let array = DVNCountries.sharedInstance().fetchCountriesFilteredByNameOn(searchController.searchBar.text!)
        
        filteredTableData = array as! [Country]
        
        self.tableView.reloadData()
    }
    
    func updateMapSearchItem() {
        
        let mapButton = UIButton(frame: CGRectMake(334, 8, 28, 28))
        mapButton.backgroundColor = UIColor.clearColor()
        mapButton.setImage(UIImage(named: "earth-america-7"), forState: .Normal)
        
        // blue tint on earth image
//        let earth = UIImage(named: "earth-america-7")
//        let tintedEarth = earth?.imageWithRenderingMode(.AlwaysTemplate)
//        mapButton.imageView!.image = tintedEarth
//        mapButton.imageView!.tintColor = UIColor.blueColor()
        
        mapButton.hidden = false
        mapButton.addTarget(self, action: #selector(CountriesTableViewController.mapAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(mapButton)
        
        mapButton.setNeedsDisplay()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return countries.count
        
        if self.searchController.active {
        
            return self.filteredTableData.count
        
        } else {
            
            let sectionInfo = DVNCountries.sharedInstance().fetchedResultsController.sections![section]
            let count = sectionInfo.numberOfObjects
            return count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CountryTableViewCellID", forIndexPath: indexPath) as! CountriesTableViewCell

        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    // Initialize the contents of the cell.
    func configureCell(cell: CountriesTableViewCell, indexPath: NSIndexPath) {
        
        //TODO - eliminates grey cell background on selection: cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        var theCountry: Country?
        if self.searchController.active {
            if let countries = DVNCountries.sharedInstance().fetchCountriesFilteredByNameOn(searchController.searchBar.text!) as? [Country] {
                theCountry = countries[indexPath.row]
            }
        } else {
            
            theCountry = DVNCountries.sharedInstance().fetchedResultsController.objectAtIndexPath(indexPath) as? Country // TODO use indexPath.row instead of indexPath?
        }

        guard let country = theCountry else {
            return
        }
        
        if let name = country.name {
            cell.name.text = name
        }
        
        if let region = country.region {
            cell.region.text = region
        }
        
        if let population = country.population {
            let popFormatter = NSNumberFormatter()
            popFormatter.numberStyle = .DecimalStyle
            cell.population.text = popFormatter.stringFromNumber(population)
        }
        
        if let languages = country.languages {
            cell.languages.text = languages
        }
        
        if let gini = country.giniCoefficient {
            cell.giniCoefficient.text = gini.stringValue
        }
        
        if let name = country.name {
            let flagImage:String = name
            if let uiImage = UIImage(named: flagImage) {
                cell.flagImageView.image = uiImage
            } else {
                cell.flagImageView.image = UIImage(named: "United Nations")
            }
        }
    }
    

    // MARK: NSFetchedResultsControllerDelegate
    
    // Any change to Core Data causes these delegate methods to be called.
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // store up changes to the table until endUpdates() is called
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        // Our project does not use sections. So we can ignore these invocations.
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .Insert:
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        case .Delete:
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! CountriesTableViewCell, indexPath: indexPath!)
            
        case .Move:
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Make the stored changes visible.
        self.tableView.endUpdates()
    }

    // MARK: notifications
    
    /* Received a notification that any updated countries are now available in core data. Update the table view. */
    func onCountriesUpdate() {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowCountryLoans" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destinationViewController as! CountryLoansTableViewController
                
                let activityIndicator = DVNActivityIndicator()
                
                activityIndicator.startActivityIndicator(tableView)
                
                var theCountry: Country?
                if self.searchController.active {
                    
                    if let countries = DVNCountries.sharedInstance().fetchCountriesFilteredByNameOn(searchController.searchBar.text!) as? [Country] {
                        theCountry = countries[indexPath.row]
                    }
                } else {
                    
                    // save the selected country
                    theCountry = DVNCountries.sharedInstance().fetchedResultsController.objectAtIndexPath(indexPath) as? Country
                }
                
                controller.country = theCountry

                activityIndicator.stopActivityIndicator()
            }
        }
        else if segue.identifier == "CountriesToMapSegueId" {
                
                let controller = segue.destinationViewController as! CountriesMapViewController
                
                controller.sourceViewController = self
                controller.navigationItem.title = "Countries"
        }
    }
}

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

class CountriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating/*, UISearchBarDelegate*/ {

    let searchController = UISearchController(searchResultsController: nil)

    var countries = [Country]()
    var filteredTableData = [Country]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Countries.getCountriesFromWebService()
        initCountriesFromCoreData()
        
        setupView()
        
        addSearchBar()
        
        navigationItem.title = "Countries"
        
        //self.edgesForExtendedLayout = .None
        //todo
        //self.navigationController?.navigationBar.translucent = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to countries from RESTCountries web service.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onCountriesUpdate", name: countriesUpdateNotificationKey, object: nil)
        
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
        
        let mapButton = UIButton(frame: CGRectMake(334, 8, 28, 28))
        mapButton.backgroundColor = UIColor.clearColor()
        mapButton.setImage(UIImage(named: "earth-america-7"), forState: .Normal)
//        if let earthImage = UIImage(named: "earth-america-7") {
//            let tintedEarth = earthImage.imageWithRenderingMode(.AlwaysTemplate)
//            mapButton.imageView!.image = tintedEarth
//            mapButton.imageView!.tintColor = UIColor.blueColor()
//        }
        mapButton.hidden = false
        mapButton.addTarget(self, action: "mapAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(mapButton)
        

    }
    
    func mapAction(sender:UIButton!)
    {
//        presentCountriesMapViewController()
//        return
        
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
        }
        
        let array = DVNCountries.sharedInstance().fetchCountriesFilteredByNameOn(searchController.searchBar.text!)
        
        
        //let array = (countries as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredTableData = array as! [Country]
        
        self.tableView.reloadData()
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
            print("\(name)")
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

    
    // MARK: UISearchBarDelegate

    // TODO remove
//    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
//        
//        let app = UIApplication.sharedApplication()
//        if /*searchController.active &&*/ app.statusBarHidden && searchController.searchBar.frame.origin.y == 0 {
//            if let container = self.searchController.searchBar.superview {
//                container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, container.frame.size.height + app.statusBarFrame.height)
//            }
//        }
//    }
    
//    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
//        
//        let app = UIApplication.sharedApplication()
//        if searchController.active && app.statusBarHidden == false && searchController.searchBar.frame.origin.y == 0 {
//            if let container = self.searchController.searchBar.superview {
//                container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, container.frame.size.height + app.statusBarFrame.height)
//            }
//        }
//    }
//
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        
//        let app = UIApplication.sharedApplication()
//        if searchController.active && app.statusBarHidden == false && searchController.searchBar.frame.origin.y == 0 {
//            if let container = self.searchController.searchBar.superview {
//                container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y, container.frame.size.width, container.frame.size.height + app.statusBarFrame.height)
//            }
//        }
//    }
    

    // MARK: - Fetched results controller
    
//    lazy var fetchedResultsController: NSFetchedResultsController = {
//        
//        // Create the fetch request
//        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
//        
//        // Add a sort descriptor to enforce a sort order on the results.
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
//        
//        // Create the Fetched Results Controller
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
//            CoreDataContext.sharedInstance().countriesScratchContext, sectionNameKeyPath: nil, cacheName: nil)
//        
//        // Return the fetched results controller. It will be the value of the lazy variable
//        return fetchedResultsController
//    } ()
//    
//    /*! Perform a fetch of Country objects to update the fetchedResultsController with the current data from the core data store. */
//    func fetchCountries() {
//        var error: NSError? = nil
//        
//        do {
//            try fetchedResultsController.performFetch()
//        } catch let error1 as NSError {
//            error = error1
//        }
//        
//        if let error = error {
//            LDAlert(viewController:self).displayErrorAlertView("Error retrieving countries", message: "Unresolved error in fetchedResultsController.performFetch \(error), \(error.userInfo)")
//        }
//    }
//
//    /*! Perform a fetch of Country objects from the countriesScratchContext filtered for those that contain the specified userInput string. */
//    func fetchCountriesFilteredByNameOn(userInput: String?) -> [AnyObject]? {
//        
//        guard let userInput = userInput else {
//            return nil
//        }
//        
//        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
//
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
//
//        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", userInput)
//        //let searchPredicate = NSPredicate(format: "SELF.name CONTAINS[c] %@", searchController.searchBar.text!)
//        
//        _ = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
//            CoreDataContext.sharedInstance().countriesScratchContext, sectionNameKeyPath: nil, cacheName: nil)
//
//        var results: [AnyObject]?
//        do {
//            results = try CoreDataContext.sharedInstance().countriesContext.executeFetchRequest(fetchRequest)
//        } catch let error1 as NSError {
//            print("Error in fetchCountriesFilteredByNameOn(): \(error1)")
//            results = nil
//        }
//        
//        return results
//    }
    
    
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
            
            print("deleting row \(indexPath!.row)")
            
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
        
        print("received notification. reloading data")
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
//        else if segue.identifier == "CartToMapSegueId" {
//            
//            self.navigationController?.setNavigationBarHidden(false, animated: false)
//            
//            let controller = segue.destinationViewController as! MapWithCheckoutViewController
//            
//            controller.sourceViewController = self
//            controller.navigationItem.title = "Countries"
//        }
    }
    
//    func presentCountriesMapViewController() {
//        
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//
//        let storyboard = UIStoryboard (name: "Main", bundle: nil)
////        let controller = storyboard.instantiateViewControllerWithIdentifier("MapWithCheckoutStoryboardID") as! MapWithCheckoutViewController
//        let controller = storyboard.instantiateViewControllerWithIdentifier("CountriesMapStoryboardID") as! CountriesMapViewController
//       // controller.sourceViewController = self
//        controller.navigationItem.title = "Countries"
//        self.navigationController?.pushViewController(controller, animated: true)
//    }
}

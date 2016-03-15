//
//  CountriesTableViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/10/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit
import CoreData

let restCountriesAPI = RESTCountries.sharedInstance()

class CountriesTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var countries = [Country]()
//    var selectedCountry: Country?
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //Countries.getCountriesFromWebService()
        initCountriesFromCoreData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to countries from RESTCountries web service.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onCountriesUpdate", name: countriesUpdateNotificationKey, object: nil)
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
    
    /*! Initialize countries collection from core data using a scratch context. */
    func initCountriesFromCoreData() {
        
        fetchCountries()
        
        // set the NSFetchedResultsControllerDelegate
        fetchedResultsController.delegate = self
    }

//    /*! Initialize countries collection from web api and persist in core data. */
//    class func getCountriesFromWebService() {
//        
//        // Acquire countries from rest api.
//        restCountriesAPI.getCountries() { countries, error in
//            
//            if let countries = countries {
//                //self.countries = countries
//                print("countries:\n\(countries)")
//            }
//            //self.tableView.reloadData()
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return countries.count

        let sectionInfo = self.fetchedResultsController.sections![section]
        let count = sectionInfo.numberOfObjects
        return count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CountryTableViewCellID", forIndexPath: indexPath) as! CountriesTableViewCell

        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    // Initialize the contents of the cell.
    func configureCell(cell: CountriesTableViewCell, indexPath: NSIndexPath) {
        
        //TODO: cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        let country = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Country
        
        //let country = self.countries[indexPath.row]
        
        if let name = country.name {
            cell.name.text = name
            print("\(name)")
        }
        
        if let region = country.region {
            cell.region.text = region
        }
        
        if let population = country.population {
            cell.population.text = population.stringValue
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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // save the selected country
        let country = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Country
        //self.selectedCountry = country
        
        // transition to the CountryLoans view controller
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("CountryLoansStoryboardID") as! CountryLoansTableViewController
        
        controller.country = country
        
        self.navigationController!.pushViewController(controller, animated: true)
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

    
    // MARK: - Navigation

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        
//        if segue.identifier == "CountryLoansSegueID" {
//            
//            // Pass the selected Country object to the CountryLoansTableViewController
//            let controller = segue.destinationViewController as! CountryLoansTableViewController
//            controller.country = self.selectedCountry
//        }
//    }


    // MARK: - Fetched results controller
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        // Create the fetch request
        let fetchRequest = NSFetchRequest(entityName: Country.entityName)
        
        // Add a sort descriptor to enforce a sort order on the results.
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        // Create the Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext:
            CoreDataStackManager.sharedInstance().scratchContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Return the fetched results controller. It will be the value of the lazy variable
        return fetchedResultsController
    } ()
    
    /* Perform a fetch of Loan objects to update the fetchedResultsController with the current data from the core data store. */
    func fetchCountries() {
        var error: NSError? = nil
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            LDAlert(viewController:self).displayErrorAlertView("Error retrieving countries", message: "Unresolved error in fetchedResultsController.performFetch \(error), \(error.userInfo)")
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
            
            print("deleting row \(indexPath!.row)")
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
        case .Update:
            
            self.configureCell(tableView.cellForRowAtIndexPath(indexPath!) as! CountriesTableViewCell, indexPath: indexPath!)
            
        case .Move:
            
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            
        default:
            return
            
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
    
}

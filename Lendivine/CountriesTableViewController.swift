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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to countries from RESTCountries web service.
        NotificationCenter.default.addObserver(self, selector: #selector(CountriesTableViewController.onCountriesUpdate), name: NSNotification.Name(rawValue: countriesUpdateNotificationKey), object: nil)
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observer for the countries update notification.
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupView() {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        updateMapSearchItem()
    }
    
    func mapAction(_ sender:UIButton!)
    {
        // Modally present the MapViewController on the main thread.
        DispatchQueue.main.async {
            
            self.navigationController?.setNavigationBarHidden(false, animated: false)

            self.performSegue(withIdentifier: "CountriesToMapSegueId", sender: self)
        }
    }
    
    /*! hide the status bar */
    override var prefersStatusBarHidden : Bool {
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
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if filteredTableData.count > 0 {
            filteredTableData.removeAll(keepingCapacity: false)
        } else {
            updateMapSearchItem()
        }
        
        let array = DVNCountries.sharedInstance().fetchCountriesFilteredByNameOn(searchController.searchBar.text!)
        
        filteredTableData = array as! [Country]
        
        self.tableView.reloadData()
    }
    
    func updateMapSearchItem() {
        
        let mapButton = UIButton(frame: CGRect(x: 334, y: 8, width: 28, height: 28))
        mapButton.backgroundColor = UIColor.clear
        mapButton.setImage(UIImage(named: "earth-america-7"), for: UIControlState())
        
        // blue tint on earth image
//        let earth = UIImage(named: "earth-america-7")
//        let tintedEarth = earth?.imageWithRenderingMode(.AlwaysTemplate)
//        mapButton.imageView!.image = tintedEarth
//        mapButton.imageView!.tintColor = UIColor.blueColor()
        
        mapButton.isHidden = false
        mapButton.addTarget(self, action: #selector(CountriesTableViewController.mapAction(_:)), for: UIControlEvents.touchUpInside)
        self.view.addSubview(mapButton)
        
        mapButton.setNeedsDisplay()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return countries.count
        
        if self.searchController.isActive {
        
            return self.filteredTableData.count
        
        } else {
            
            let sectionInfo = DVNCountries.sharedInstance().fetchedResultsController.sections![section]
            let count = sectionInfo.numberOfObjects
            return count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCellID", for: indexPath) as! CountriesTableViewCell

        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    // Initialize the contents of the cell.
    func configureCell(_ cell: CountriesTableViewCell, indexPath: IndexPath) {
        
        //TODO - eliminates grey cell background on selection: cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        var theCountry: Country?
        if self.searchController.isActive {
            if let countries = DVNCountries.sharedInstance().fetchCountriesFilteredByNameOn(searchController.searchBar.text!) as? [Country] {
                theCountry = countries[indexPath.row]
            }
        } else {
            
            theCountry = DVNCountries.sharedInstance().fetchedResultsController.object(at: indexPath)
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
            let popFormatter = NumberFormatter()
            popFormatter.numberStyle = .decimal
            cell.population.text = popFormatter.string(from: population)
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // store up changes to the table until endUpdates() is called
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        // Our project does not use sections. So we can ignore these invocations.
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            
            self.configureCell(tableView.cellForRow(at: indexPath!) as! CountriesTableViewCell, indexPath: indexPath!)
            
        case .move:
            
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Make the stored changes visible.
        self.tableView.endUpdates()
    }

    // MARK: notifications
    
    /* Received a notification that any updated countries are now available in core data. Update the table view. */
    func onCountriesUpdate() {
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowCountryLoans" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let controller = segue.destination as! CountryLoansTableViewController
                
                let activityIndicator = DVNActivityIndicator()
                
                activityIndicator.startActivityIndicator(tableView)
                
                var theCountry: Country?
                if self.searchController.isActive {
                    
                    if let countries = DVNCountries.sharedInstance().fetchCountriesFilteredByNameOn(searchController.searchBar.text!) as? [Country] {
                        theCountry = countries[indexPath.row]
                    }
                } else {
                    
                    // save the selected country
                    theCountry = DVNCountries.sharedInstance().fetchedResultsController.object(at: indexPath)
                }
                
                controller.country = theCountry

                activityIndicator.stopActivityIndicator()
            }
        }
        else if segue.identifier == "CountriesToMapSegueId" {
                
                let controller = segue.destination as! CountriesMapViewController
                
                controller.sourceViewController = self
                controller.navigationItem.title = "Countries"
        }
    }
}

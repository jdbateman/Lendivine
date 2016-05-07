//
//  CountriesMapViewController.swift
//  Lendivine
//
//  Created by john bateman on 5/7/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// This is the Countries Map View Controller which presents an MKMapView that the user can touch to initiate a search for loans in the selected country.


import UIKit
import MapKit

class CountriesMapViewController: MapViewController, UIGestureRecognizerDelegate {

    var tapRecognizer: UITapGestureRecognizer? = nil
    
    var annotation: MKAnnotation?
    var countryName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.kivaAPI = KivaAPI.sharedInstance

        modifyBarButtonItems()

        initTapRecognizer()
    }
    
    func modifyBarButtonItems() {
        
        let loansByListButton = UIBarButtonItem(image: UIImage(named: "Donate-32"), style: .Plain, target: self, action: "onLoansByListButtonTap")
        navigationItem.setRightBarButtonItems([loansByListButton], animated: true)
        
        // remove back button
        navigationItem.hidesBackButton = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        initTapRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        deinitTapRecognizer()
    }
    
    
    // MARK: Tap gesture recognizer
    
    func initTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action:Selector("handleSingleTap:"))
        
        if let tr = tapRecognizer {
            tr.numberOfTapsRequired = 1
            self.mapView.addGestureRecognizer(tr)
            self.mapView.userInteractionEnabled = true
        }
    }
    
    func deinitTapRecognizer() {
        self.mapView.removeGestureRecognizer(self.tapRecognizer!)
    }
    
    // User tapped somewhere on the view. End editing.
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        
        // clear pins
        if let annotation = self.annotation {
            self.mapView.removeAnnotation(annotation)
        }
        
        if let point = tapRecognizer?.locationInView(self.mapView) {
        
            let tapPoint:CLLocationCoordinate2D = self.mapView.convertPoint(point, toCoordinateFromView: self.view)
            let location = CLLocation(latitude: tapPoint.latitude , longitude: tapPoint.longitude)
            
            print("coordinates: lat: \(tapPoint.latitude) lon: \(tapPoint.longitude)")
            
            // add a pin on the map
            let pin = MKPointAnnotation()
            pin.coordinate = tapPoint
            self.mapView.addAnnotation(pin)
            self.annotation = pin
            
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) {
                placemarks, error in
                
                if placemarks != nil {
                    if let placemark = placemarks?.first {
                        self.countryName = placemark.country
                        print("country: \(placemark.country)")
                        
                        // show CountryLoans view controller
                        self.presentCountryLoansController()
                    }
                } else {
                    self.showAlert()
                }
            }
        }
    }
    
    
    // MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "CountriesMapToCountryLoans" {
            
                let controller = segue.destinationViewController as! CountryLoansTableViewController
                
                let activityIndicator = DVNActivityIndicator()
                
                activityIndicator.startActivityIndicator(self.view)
                
                var theCountry: Country?
                if let countries = DVNCountries.fetchCountriesFilteredByNameOn(self.countryName) as? [Country] {
                    theCountry = countries.first
                }
                
                controller.country = theCountry
                
                activityIndicator.stopActivityIndicator()

        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentCountryLoansController() {
        dispatch_async(dispatch_get_main_queue()) {
            self.performSegueWithIdentifier("CountriesMapToCountryLoans", sender: self)
        }
    }
    
    
    // MARK: Helpers

    func showAlert() {
     
        let alertController = UIAlertController(title: "Country Not Found", message: "Zoom in and try again.\n\nHint: Tap near the center of the country." , preferredStyle: .Alert)

        let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            // do nothing
        }
        
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}

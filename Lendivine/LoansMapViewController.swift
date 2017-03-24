//
//  LoansMapViewController.swift
//  Lendivine
//
//  Created by john bateman on 5/22/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit
import MapKit

class LoansMapViewController: MapViewController, UIGestureRecognizerDelegate  {

    //var tapRecognizer: UITapGestureRecognizer? = nil
    var longPressedRecognizer: UILongPressGestureRecognizer? = nil
    
    var annotation: MKAnnotation?
    var countryName: String?
    var cityName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initTapRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initTapRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deinitTapRecognizer()
    }

    
    // MARK: Tap gesture recognizer
    
    func initTapRecognizer() {
        
//        tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(LoansMapViewController.handleSingleTap(_:)))
//        
//        if let tr = tapRecognizer {
//            tr.numberOfTapsRequired = 1
//            self.mapView.addGestureRecognizer(tr)
//            self.mapView.userInteractionEnabled = true
//        }
        
        longPressedRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(LoansMapViewController.handleLongPressed(_:)))
        
        if let lpr = longPressedRecognizer {
            self.mapView.addGestureRecognizer(lpr)
            self.mapView.isUserInteractionEnabled = true
        }
    }
    
    func deinitTapRecognizer() {
        
//        if let tr = self.tapRecognizer {
//            self.mapView.removeGestureRecognizer(tr)
//        }
        if let lpr = self.longPressedRecognizer {
            self.mapView.removeGestureRecognizer(lpr)
        }
    }
    
    // User long pressed somewhere on the view. End editing.
    func handleLongPressed(_ sender: UILongPressGestureRecognizer) {
        
        // clear pins
        if let annotation = self.annotation {
            self.mapView.removeAnnotation(annotation)
        }
        
        if let point = longPressedRecognizer?.location(in: self.mapView) {
            
            let tapPoint:CLLocationCoordinate2D = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            let location = CLLocation(latitude: tapPoint.latitude , longitude: tapPoint.longitude)
            
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
                        
                        if let city = placemark.addressDictionary!["City"] as? String {
                            self.cityName = city
                        }
                        
                        // show CountryLoans view controller
                        self.presentCountryLoansController()
                    }
                } else {
                    if (error?._domain == kCLErrorDomain) && (error?._code == 2) {
                        LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: "Unable to Search for loans in the selected country.")
                    } else {
                        self.showAlert()
                    }
                }
            }
        }
    }

//    func handleSingleTap(recognizer: UITapGestureRecognizer) {
//        print("single tap")
//    }
    
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LoansMapToCountryLoans" {
            
            let controller = segue.destination as! CountryLoansTableViewController
            
            let activityIndicator = DVNActivityIndicator()
            
            activityIndicator.startActivityIndicator(self.view)
            
            var theCountry: Country?
            if let countries = DVNCountries.sharedInstance().fetchCountriesFilteredByNameOn(self.countryName) as? [Country] {
                theCountry = countries.first
            }
            
            controller.country = theCountry
            
            activityIndicator.stopActivityIndicator()
        }
    }
    
    /* Modally present the MapViewController on the main thread. */
    func presentCountryLoansController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "LoansMapToCountryLoans", sender: self)
        }
    }
    
    
    // MARK: Helpers
    
    func showAlert() {
        
        let alertController = UIAlertController(title: "Country Not Found", message: "Zoom in and try again.\n\nHint: Tap near the center of the country." , preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            // do nothing
        }
        
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

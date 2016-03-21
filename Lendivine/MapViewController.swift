//
//  MapViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/19/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  Acknowledgement: Used code from Udacity PinSample to display annotations on the MapView
//
//  This file contains the MapViewController, which displays pins representing Loans on a MKMapView.

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var appDelegate: AppDelegate!
    
    /* a reference to the studentLocations singleton */
//TODO remove>    var studentLocations = StudentLocations.sharedInstance()
    
    /* The collection of KivaLoan objects to map. This value should be set before instantiating an instance of the MapViewController. */
    var loans: [KivaLoan]?
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = false
        
        // Additional bar button items
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
        let pinButton = UIBarButtonItem(image: UIImage(named: "pin"), style: .Plain, target: self, action: "onPinButtonTap")
        navigationItem.setRightBarButtonItems([refreshButton, pinButton], animated: true)
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set the mapView delegate to this view controller
        mapView.delegate = self
        
        // Set the region to North America
        setMapRegionToNorthAmerica()
        //setMapRegionToLargestExtent()
        
        // configure mapView
        mapView.showsPointsOfInterest = false
        mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a notification observer for updates to student location data from Parse.
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onStudentLocationsUpdate", name: studentLocationsUpdateNotificationKey, object: nil)
        
        // Clear any existing pins before redrawing them (e.g. if navigating back to the map view from the InfoPosting view.)
        removeAllPins()
        
        // Draw the pins now (as it is conceivable that the notification arrived prior to the observer being registered.)
        createPins()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

// TODO
//        // If not logged in present the LoginViewController.
//        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        if delegate.loggedIn == false {
//            displayLoginViewController()
//        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setNeedsDisplay()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove observer for the studentLocations update notification.
//TODO        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: button handlers
    
    /* Pin button was selected. */
    func onPinButtonTap() {
        presentLoanDetailViewController(nil) // todo - probable shouldn't pass nil for the loan
    }
    
    @IBAction func onBackButtonTap(sender: UIBarButtonItem) {
    
    
    }
    
// TODO
//    /* Refresh button was selected. */
//    func onRefreshButtonTap() {
//        // refresh the collection of student locations from Parse
//        studentLocations.reset()
//        studentLocations.getStudentLocations(0) { success, errorString in
//            if success == false {
//                if let errorString = errorString {
//                    OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: errorString)
//                } else {
//                    OTMError(viewController:self).displayErrorAlertView("Error retrieving Locations", message: "Unknown error")
//                }
//            }
//        }
//        
//        dispatch_async(dispatch_get_main_queue()) {
//            self.mapView.setNeedsDisplay()
//        }
//    }

// TODO - cleanup
//    /* logout of Facebook else logout of Udacity session */
//    @IBAction func onLogoutButtonTap(sender: AnyObject) {
//        startActivityIndicator()
//        
//        // Facebook logout
//        if (FBSDKAccessToken.currentAccessToken() != nil)
//        {
//            // User is logged in with Facebook. Log user out of Facebook.
//            let loginManager = FBSDKLoginManager()
//            loginManager.logOut()
//            if (FBSDKAccessToken.currentAccessToken() == nil)
//            {
//                self.appDelegate.loggedIn = false
//            }
//            self.stopActivityIndicator()
//            self.displayLoginViewController()
//        } else {
//            // Udacity logout
//            RESTClient.sharedInstance().logoutUdacity() {result, error in
//                self.stopActivityIndicator()
//                if error == nil {
//                    // successfully logged out
//                    self.appDelegate.loggedIn = false
//                    self.displayLoginViewController()
//                } else {
//                    println("Udacity logout failed")
//                    // no display to user
//                }
//            }
//        }
//    }
    
    
    // MARK: Manage map annotations
    
    /* Create an annotation for each studentLocation and display them on the map */
    func createPins() {
        
        if let loans = self.loans {
            
            // A collection of point annotations to be displayed on the map view
            var annotations = [MKPointAnnotation]()
            
            // Create an annotation for each loan in loans
//            var loanCount = 0
            for loan in loans {
                
                guard let coordinate = KivaLoan.getCoordinatesForLoan(loan) else {
                    return
                }
                
//                // get latitude and longitude from loan and save as CCLocationDegree type (a Double type)
//                guard let geo = loan.geo else {return}
//                let geoCoordsArray = geo.characters.split{$0 == " "}.map(String.init)
//                
//                guard let latitude = Double(geoCoordsArray[0]) else {return}
//                guard let longitude = Double(geoCoordsArray[1]) else {return}
//                let lat = CLLocationDegrees(latitude)
//                let long = CLLocationDegrees(longitude)
//                
//                // The lat and long are used to create a CLLocationCoordinates2D instance.
//                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                // Create the annotation, setting the coordinate, title, and subtitle properties
                let annotation = DVNPointAnnotation() // MKPointAnnotation()
                annotation.coordinate = coordinate
                
                if let name = loan.name, country = loan.country {
                    annotation.title = "\(name) in \(country)"
                }

                if let id = loan.id {
                    annotation.subtitle = id.stringValue // Later, when the user selects this pin, do a fetch on this id to get the KivaLoan object.
                }

                if let imageId = loan.imageID {
                    annotation.imageID = imageId
                }
                
                annotation.loan = loan
                
//                loan.getImage() {
//                    success, error, image in
//                    
//                    if success {
//                        annotation.annotationImage = image
//                    }
//                    
//                    loanCount++
//                }
                
                // Add annotation to the annotations collection.
                annotations.append(annotation)
                
//                if loanCount == loans.count {
//                    
//                    // Add the annotations to the map.
//                    self.mapView.addAnnotations(annotations)
//                    
//                    self.mapView.setNeedsDisplay()
//                }
            }
            
            // Add the annotations to the map.
            self.mapView.addAnnotations(annotations)
            
            self.mapView.setNeedsDisplay()
        }
    }
    
    /*
    @brief - Remove all annotations from the MKMapView.
    Acknowledgement:  nielsbot, SO for filter technique to remove all but users current location.
    */
    func removeAllPins() {
        let annotationsToRemove = self.mapView.annotations.filter { $0 !== self.mapView.userLocation }
        self.mapView.removeAnnotations( annotationsToRemove )
    }
    
    
    // MARK: MKMapViewDelegate
    
    // Create an accessory view for the pin annotation callout when it is added to the map view
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation .isKindOfClass(DVNPointAnnotation) else {
            return nil
        }
        let pointAnnotation: DVNPointAnnotation = annotation as! DVNPointAnnotation
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView /*MKAnnotationView*/ /*MapPin*/ (annotation: annotation, reuseIdentifier: reuseId)
            pinView!.enabled = true // todo needed?
            pinView!.canShowCallout = true // true
            pinView!.pinColor = .Red
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)  // DetailDisclosure, InfoLight, InfoDark, ContactAdd
            pinView!.animatesDrop = true

// #1           let btn = UIButton(type: .DetailDisclosure)
//            pinView!.rightCalloutAccessoryView = btn
//            
//            //----
//            pinView = CustomView(annotation: pointAnnotation, reuseIdentifier:reuseId)
//            //pinView!.image = UIImage(named:"pin-map-7.png")
            
            // Display the lendee's image on the annotation
            if let loan = pointAnnotation.loan {
                loan.getImage() {
                    success, error, image in
                    
                    if success {
                        // pointAnnotation.annotationImage = image
                        pinView!.image = image;
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.mapView.setNeedsDisplay()
                        }
                    }
                }
            }
            
// #1                let button : UIButton = UIButton(type:.DetailDisclosure)
//                button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
//                pinView!.rightCalloutAccessoryView=button
//                pinView!.canShowCallout = false
        }
        else {
            pinView!.annotation = annotation
        }
            
        pinView!.image = UIImage(named:"Albania.png") //placeholder  "pin-map-7.png"
        return pinView
    }
    
/* #1
    // Create an accessory view for the pin annotation callout when it is added to the map view
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation .isKindOfClass(DVNPointAnnotation) else {
            return nil
        }
        let pointAnnotation: DVNPointAnnotation = annotation as! DVNPointAnnotation
        
        let reuseId = "mapPin" // "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? CustomView // as? MapPin //as? MKPinAnnotationView
        
        if pinView == nil {
//            pinView = /*MKPinAnnotationView*/ /*MKAnnotationView*/ MapPin(annotation: annotation, reuseIdentifier: reuseId)
//            pinView!.enabled = true // todo needed?
//            pinView!.canShowCallout = false // true
////            pinView!.pinColor = .Red
////            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)  // DetailDisclosure, InfoLight, InfoDark, ContactAdd
////            pinView!.animatesDrop = true
//            
//            let btn = UIButton(type: .DetailDisclosure)
//            pinView!.rightCalloutAccessoryView = btn
            
            //----
            pinView = CustomView(annotation: pointAnnotation, reuseIdentifier:reuseId)
            //pinView!.image = UIImage(named:"pin-map-7.png")
            
            // Display the lendee's image on the annotation
            if let loan = pointAnnotation.loan {
                loan.getImage() {
                success, error, image in
                
                if success {
                    // pointAnnotation.annotationImage = image
                    pinView!.image = image;
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.setNeedsDisplay()
                    }
                }
            }
            
            let button : UIButton = UIButton(type:.DetailDisclosure) // as! UIButton
            button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
            pinView!.rightCalloutAccessoryView=button
            pinView!.canShowCallout = false
        }
        else {
            pinView!.annotation = annotation
        }
        
        pinView!.image = UIImage(named:"pin-map-7.png") //placeholder
        return pinView
    }
*/
  
// #2 - enable this function to process tap on the MKAnnotationView
    
   func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        let ano = view.annotation as! DVNPointAnnotation
    
//        let capital = view.annotation as! MapPinCallout
//        let placeName = capital.title
//        let placeInfo = capital.info

// todo
//        let ac = UIAlertController(title: "test title", message: "test message", preferredStyle: .Alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//        presentViewController(ac, animated: true, completion: nil)

// todo
        if let loan = ano.loan {
            presentLoanDetailViewController(loan)
        }
    }
    
//   func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        
////        let capital = view.annotation as! MapPinCallout
////        let placeName = capital.title
////        let placeInfo = capital.info
//        
//        let ac = UIAlertController(title: "test title", message: "test message", preferredStyle: .Alert)
//        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//        presentViewController(ac, animated: true, completion: nil)
//    }
    
//    // This delegate method is implemented to respond to taps. It opens the system browser
//    // to the URL specified in the annotationViews subtitle property.
//    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        
//        if control == annotationView.rightCalloutAccessoryView {
//            if let urlString = annotationView.annotation!.subtitle {
////TODO                showUrlInEmbeddedBrowser(urlString)
//            }
//        }
//    }
    
    // -------
    
//#1    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!){
//        
//        var viewC:UIView=UIView(frame: CGRectMake(0, 0, 50, 50))
//        viewC.backgroundColor = UIColor.blackColor()
//        
//        view.addSubview(viewC)
//        viewC.center = CGPointMake(viewC.bounds.size.width*0.1, -viewC.bounds.size.height*0.5)
//    }
    
    //--------------- >
 /*
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        if let mapPin = view as? MapPin {
            updatePinPosition(mapPin)
        }
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        if let mapPin = view as? MapPin {
            if mapPin.preventDeselection {
                mapView.selectAnnotation(view.annotation!, animated: false)
            }
        }
    }
    
    func updatePinPosition(pin:MapPin) {
        let defaultShift:CGFloat = 50
        let pinPosition = CGPointMake(pin.frame.midX, pin.frame.maxY)
        
        let y = pinPosition.y - defaultShift
        
        let controlPoint = CGPointMake(pinPosition.x, y)
        let controlPointCoordinate = mapView.convertPoint(controlPoint, toCoordinateFromView: mapView)
        
        mapView.setCenterCoordinate(controlPointCoordinate, animated: true)
    }
 */   
    //--------------- <
    
    
    
    
    
    // MARK: Helper functions
// TODO
//    /* Received a notification that studentLocations have been updated with new data from Parse. Recreate the pins for all locations. */
//    func onStudentLocationsUpdate() {
//        // clear the pins
//        removeAllPins()
//        
//        // redraw the pins
//        createPins()
//        
//        dispatch_async(dispatch_get_main_queue()) {
//            self.mapView.setNeedsDisplay()
//        }
//    }

// TODO
//    /* Modally present the Login view controller. */
//    func displayLoginViewController() {
//        var storyboard = UIStoryboard (name: "Main", bundle: nil)
//        var controller = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
//        self.presentViewController(controller, animated: true, completion: nil);
//    }
//    
    /* Modally present the LoanDetail view controller. */
    func presentLoanDetailViewController(loan: KivaLoan?) {
        guard let loan = loan else {
            return
        }
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoanDetailStoryboardID") as! LoanDetailViewController
        controller.loan = loan
        self.presentViewController(controller, animated: true, completion: nil);
    }
    
    /* show activity indicator */
    func startActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    /* hide acitivity indicator */
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    /* Display url in external Safari browser. */
    func showUrlInExternalWebKitBrowser(url: String) {
        if let requestUrl = NSURL(string: url) {
            UIApplication.sharedApplication().openURL(requestUrl)
        }
    }
    
    /* Display url in an embeded webkit browser in the navigation controller. */
    func showUrlInEmbeddedBrowser(url: String) {
        var storyboard = UIStoryboard (name: "Main", bundle: nil)
//TODO ->        var controller = storyboard.instantiateViewControllerWithIdentifier("WebViewStoryboardID") as! WebViewController
//        controller.url = url
//        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    /* Set the mapview to show north america. */
    func setMapRegionToNorthAmerica() {
        
        // center of U.S.
        let location = CLLocationCoordinate2D(
            latitude: 49.50, // 39.50,
            longitude: -98.35
        )
        // visible span in degrees lat, lon
        let span = MKCoordinateSpanMake(70, 30)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    /*! Set map region to display the coordinates of all loans in this object's loans collection. */
    func setMapRegionToLargestExtent() {
        
        var lowestLatitude = 0.0
        var largestLatitude = 0.0
        var lowestLongitude = 0.0
        var largestLongitude = 0.0
        
        // determine maximum extent
        if let loans = self.loans {
        
            for loan in loans {
                
                if let coordinates = KivaLoan.getCoordinatesForLoan(loan) {
                    lowestLatitude = coordinates.latitude < lowestLatitude ? coordinates.latitude : lowestLatitude
                    largestLatitude = coordinates.latitude > largestLatitude ? coordinates.latitude : largestLatitude
                    lowestLongitude = coordinates.longitude < lowestLongitude ? coordinates.longitude : lowestLongitude
                    largestLongitude = coordinates.longitude > largestLongitude ? coordinates.longitude : largestLongitude
                }
                print("latitude range: \(lowestLatitude) -> \(largestLatitude), longitude range: \(lowestLongitude) -> \(largestLongitude)")
            }
            
            // add some margin on edges of the map
            let margin = 5.0
            lowestLatitude = lowestLatitude < 80.0 ? 85.0 : lowestLatitude - margin
            largestLatitude = largestLatitude > 80.0 ? 85.0 : largestLatitude + margin
            lowestLongitude = lowestLongitude < 170.0 ? 175.0 : lowestLongitude - margin
            largestLongitude = largestLongitude > 170.0 ? 175.0 : largestLongitude + margin
        }
        
        // center
        let centerLatitude = (lowestLatitude + largestLatitude) / 2
        let centerLongitude = (lowestLongitude + largestLongitude) / 2
        let location = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        // visible span in degrees lat, lon
        let span = MKCoordinateSpanMake(abs(largestLatitude - lowestLatitude), abs(largestLongitude - lowestLongitude))
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
    }

//moved to KivaLoan class
//    /* Return mappable coordinates for a KivaLoan object */
//    func getCoordinatesForLoan(loan: KivaLoan) -> CLLocationCoordinate2D? {
//        
//        // get latitude and longitude from loan and save as CCLocationDegree type (a Double type)
//        guard let geo = loan.geo else {return nil}
//        let geoCoordsArray = geo.characters.split{$0 == " "}.map(String.init)
//        
//        guard let latitude = Double(geoCoordsArray[0]) else {return nil}
//        guard let longitude = Double(geoCoordsArray[1]) else {return nil}
//        let lat = CLLocationDegrees(latitude)
//        let long = CLLocationDegrees(longitude)
//        
//        // The lat and long are used to create a CLLocationCoordinates2D instance.
//        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
//        
//        return coordinate
//    }

}


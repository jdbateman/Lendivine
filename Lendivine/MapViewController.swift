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

class MapViewController: DVNViewController, MKMapViewDelegate {
    
    var appDelegate: AppDelegate!
    
    /* The collection of KivaLoan objects to map. This value should be set before instantiating an instance of the MapViewController. */
    var loans: [KivaLoan]?
    var sourceViewController: UIViewController?
    
    var showRefreshButton = true
    
    @IBOutlet weak var mapView: MKMapView!
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50)) as UIActivityIndicatorView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMapView()
    }
    
    func configureMapView() {
        
        setupBarButtonItems()
        
        // get a reference to the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // set the mapView delegate to this view controller
        mapView.delegate = self
        
        // Set the region to North America
        if let theLoans = loans {
            if theLoans.count > 0 {
                setMapRegionToCountryForLoan(theLoans[0])
            }
        }
        
        // configure mapView
        mapView.showsPointsOfInterest = false
        mapView.showsUserLocation = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshMapPins()
    }
    
    /*! hide the status bar */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setupBarButtonItems() {
    
        navigationItem.hidesBackButton = true
        
        var barButtonItems = [UIBarButtonItem]()
        
        let loansByListButton = UIBarButtonItem(image: UIImage(named: "Donate-32"), style: .Plain, target: self, action: "onLoansByListButtonTap")
        barButtonItems.append(loansByListButton)
        
        if showRefreshButton {
            let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "onRefreshButtonTap")
            barButtonItems.append(refreshButton)
        }
        
        navigationItem.setRightBarButtonItems(barButtonItems, animated: true)
    }
    
    func refreshMapPins() {
        
        // Clear any existing pins before redrawing them (e.g. if navigating back to the map view from the InfoPosting view.)
        removeAllPins()
        
        // Draw the pins now (as it is conceivable that the notification arrived prior to the observer being registered.)
        createPins()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.setNeedsDisplay()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: button handlers
    
    func onLoansByListButtonTap() {
        popViewController()
    }
    
    /* Refresh button was selected. */
    func onRefreshButtonTap() {
        
        // Search Kiva.org for the next page of Loan results.
        self.populateLoans(LoansTableViewController.KIVA_LOAN_SEARCH_RESULTS_PER_PAGE) { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    //self.fetchLoans()
                    self.refreshMapPins()
                }
            } else {
                print("failed to populate loans. error: \(error?.localizedDescription)")
            }
        }
    }
    
    
    // MARK: Manage map annotations
    
    /* Create an annotation for each studentLocation and display them on the map */
    func createPins() {
        
        if let loans = self.loans {
            
            print("creating Pins for \(loans.count) loans")
            var i = 0
            
            // A collection of point annotations to be displayed on the map view
            var annotations = [DVNPointAnnotation]()
            
            // Create an annotation for each loan in loans
            for loan in loans {
                
                guard let coordinate = KivaLoan.getCoordinatesForLoan(loan) else {
                    return
                }
                
                // Create the annotation, setting the coordinate, title, and subtitle properties
                let annotation = DVNPointAnnotation() // MKPointAnnotation()
                annotation.coordinate = coordinate
                
                if let name = loan.name, country = loan.country {
                    annotation.title = "\(name) in \(country)"
                }
//todo - remove
//                if let id = loan.id {
//                    annotation.subtitle = id.stringValue // Later, when the user selects this pin, do a fetch on this id to get the KivaLoan object.
//                }
                
                if let _ = loan.id {
                    var subtitleText = ""
                    if let sector = loan.sector {
                        subtitleText = sector
                    }
                    if let amount = loan.loanAmount {
                        let formatter = NSNumberFormatter()
                        formatter.numberStyle = .CurrencyStyle
                        if let amountString = formatter.stringFromNumber(amount) {
                            subtitleText.appendContentsOf(": ")
                            subtitleText.appendContentsOf(amountString)
                        }
                    }
                    annotation.subtitle = subtitleText
                }

                if let imageId = loan.imageID {
                    annotation.imageID = imageId
                }
                
                annotation.loan = loan
                
                // Add annotation to the annotations collection.
                annotations.append(annotation)
                
                print("appended another loan: \(++i)") // todo - remove debug
            }
            
            print("Finished appending \(i) annotations. annotations now contains \(annotations.count) annotations")
            
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
//    func xmapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        
//        let reuseID = "myAnnotationView"
//        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
//        if (annotationView == nil) {
//            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
//        }
//        if let annotationView = annotationView {
//            annotationView.image = UIImage(named: "Albania.png")
//        }
//        return annotationView
//    }
    
//    func XmapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//    
//        guard annotation .isKindOfClass(DVNPointAnnotation) else {
//            return nil
//        }
//        let pointAnnotation: DVNPointAnnotation = annotation as! DVNPointAnnotation
//        
//        let reuseId = "pin"
//        
//        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
//        
//        if pinView == nil {
//            // TODO: in this file finish updating the annotation left callout with loan recipient's image
//            pinView = MKPinAnnotationView /*MKAnnotationView*/ /*MapPin*/ (annotation: annotation, reuseIdentifier: reuseId)
//            pinView!.enabled = true // todo needed?
//            pinView!.canShowCallout = true
//            pinView!.pinColor = .Red
//            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
//            pinView!.animatesDrop = false // TODO - change to true
//
//// #1           let btn = UIButton(type: .DetailDisclosure)
////            pinView!.rightCalloutAccessoryView = btn
////            
////            //----
////            pinView = CustomView(annotation: pointAnnotation, reuseIdentifier:reuseId)
////            //pinView!.image = UIImage(named:"pin-map-7.png")
//            
//            // Display the lendee's image on the annotation
//            if let loan = pointAnnotation.loan {
//                loan.getImage() {
//                    success, error, image in
//                    
//                    if success {
//                        // pointAnnotation.annotationImage = image
//                        pinView!.image = image
//                        
//                        dispatch_async(dispatch_get_main_queue()) {
//                            self.mapView.setNeedsDisplay()
//                        }
//                    }
//                }
//            }
//            
//// #1                let button : UIButton = UIButton(type:.DetailDisclosure)
////                button.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
////                pinView!.rightCalloutAccessoryView=button
////                pinView!.canShowCallout = false
//        }
//        else {
//            pinView!.annotation = annotation
//        }
//        
//        if let annotationImage = UIImage(named:"Albania.png") {
//            pinView!.image = annotationImage // getThumbnailForImage(annotationImage)
//        }
//        return pinView
//    }
    
    /*! Create an accessory view for the pin annotation callout when it is added to the map view */
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        guard annotation .isKindOfClass(DVNPointAnnotation) else {
            return nil
        }
        let pointAnnotation: DVNPointAnnotation = annotation as! DVNPointAnnotation
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            //pinView!.image = UIImage(named: "pin-map-7")

            // Display the lendee's image on the annotation
            if let loan = pointAnnotation.loan {
                loan.getImage() {
                    success, error, image in
                    
                    if success {
                        // pointAnnotation.annotationImage = image
                        pinView!.leftCalloutAccessoryView = self.getCustomAccessoryViewForImage(image)
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.mapView.setNeedsDisplay()
                        }
                    }
                }
            }
            
            // Add image to left callout
            if let loan = pointAnnotation.loan {
                let flagImageName = loan.getNameOfFlagImage()
                pinView!.leftCalloutAccessoryView = getCustomAccessoryViewForImageNamed(flagImageName)
            }
            
            // Add detail button to right callout
            //var calloutButton = UIButton(type: .DetailDisclosure) // as UIButton
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    func getCustomAccessoryViewForImage(image:UIImage?) -> UIImageView? {
        if let image = image {
            if let thumb = getThumbnailForImage(image) {
                return UIImageView(image: thumb)
            }
        }
        return nil
    }
    
    func getCustomAccessoryViewForImageNamed(imageName:String) -> UIImageView? {
        
        if let annotationImage = UIImage(named:imageName) {
            if let image = getThumbnailForImage(annotationImage) {
                return UIImageView(image: image)
            }
        }
        return nil
    }
    
    func getThumbnailForImage(fullImage:UIImage) -> UIImage?
    {
        let resizedImageView = UIImageView(frame: CGRectMake(0, 0, 45, 45))
        resizedImageView.layer.borderColor = UIColor.whiteColor().CGColor
        resizedImageView.layer.borderWidth = 2.2
        resizedImageView.contentMode = UIViewContentMode.ScaleAspectFit // or ScaleAspectFill
        resizedImageView.image = fullImage
        
        UIGraphicsBeginImageContextWithOptions(resizedImageView.frame.size, false, 0.0)
        resizedImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnailImage
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

    /* Modally present the LoanDetail view controller. */
    func presentLoanDetailViewController(loan: KivaLoan?) {
        guard let loan = loan else {
            return
        }
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("LoanDetailStoryboardID") as! LoanDetailViewController
        controller.loan = loan

        // add the view controller to the navigation controller stack
        self.navigationController?.pushViewController(controller, animated: true)
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
    
// todo - remove - unused
//    /* Display url in external Safari browser. */
//    func showUrlInExternalWebKitBrowser(url: String) {
//        if let requestUrl = NSURL(string: url) {
//            UIApplication.sharedApplication().openURL(requestUrl)
//        }
//    }
//    
//    /* Display url in an embeded webkit browser in the navigation controller. */
//    func showUrlInEmbeddedBrowser(url: String) {
//        var storyboard = UIStoryboard (name: "Main", bundle: nil)
//    }
    
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

    /* Set the mapview to show the specified country. */
    func setMapRegionToCountryForLoan(loan:KivaLoan) {
        
        // get latitude and longitude from loan and save as CCLocationDegree type (a Double type)
        guard let geo = loan.geo else {return}
        let geoCoordsArray = geo.characters.split{$0 == " "}.map(String.init)

        guard let latitude = Double(geoCoordsArray[0]) else {return}
        guard let longitude = Double(geoCoordsArray[1]) else {return}
        let lat = CLLocationDegrees(latitude)
        let long = CLLocationDegrees(longitude)

        print("\(loan.country) coordinates: (\(lat), \(long))")
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        _ = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        // center
        let location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long
        )
        // visible span in degrees lat, lon
        let span = MKCoordinateSpanMake(100, 50)  // 70, 30
        
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
    
    func popViewController() {
        
        if let src = self.sourceViewController {
            src.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func createCustomBackButton() {
        let customBackButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancelButton")
        navigationItem.setLeftBarButtonItem(customBackButton, animated: true)
    }
    
    func onCancelButton() {
        popViewController()
    }
}


//
//  MyMapViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/6/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit
import MapKit

class MyMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        addPin()
    }


    func addPin() {
        let annotation = MKPointAnnotation()
        let locationCoordinate = CLLocationCoordinate2DMake(37.783333, -122.416667)
        annotation.coordinate = locationCoordinate
        annotation.title = "blah blah"
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        UIAlertView(title: "tapped Annotation!", message: view.annotation!.title!, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    func xmapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("myAnnotationView")
        if (annotationView == nil) {
            // use this to set the annotation image
            // annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            // annotationView!.image = UIImage(named: "Donate-52")
            
            // use the standard mapkit pin for the annotation image
            var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotationView")
            pinView.pinColor = .Purple
            
            // customize the annotation's callout
//            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotationView")
//            pinView.pinColor = .Purple
//            pinView.animatesDrop = true
//            pinView.canShowCallout = true
//            pinView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)  // DetailDisclosure, InfoLight, InfoDark, ContactAdd
//            let myCustomImageView = UIImageView(image: UIImage(named: "Donate-32"))
//            pinView.leftCalloutAccessoryView = myCustomImageView
            
            return pinView
        }
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.image = UIImage(named: "pin-map-7")
            
            // Add image to left callout
            //let mugIconView = UIImageView(image: UIImage(named: "Donate-32"))
            pinView!.leftCalloutAccessoryView = getCustomAccessoryView("Albania.png") //mugIconView
            
            // Add detail button to right callout
            //var calloutButton = UIButton(type: .DetailDisclosure) // as UIButton
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func getCustomAccessoryView(imageName:String) -> UIImageView? {
        
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
    
//    // This code snippet assumes that an annotation for the Golden Gate Bridge has already been added to the map view.
//    
//    - (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
//    {
//        // Try to dequeue an existing pin view first (code not shown).
//        
//        // If no pin view already exists, create a new one.
//        MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:BridgeAnnotationIdentifier];
//        customPinView.pinColor = MKPinAnnotationColorPurple;
//        customPinView.animatesDrop = YES;
//        customPinView.canShowCallout = YES;
//        
//        // Because this is an iOS app, add the detail disclosure button to display details about the annotation in another view.
//        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
//        customPinView.rightCalloutAccessoryView = rightButton;
//        
//        // Add a custom image to the left side of the callout.
//        UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MyCustomImage.png"]];
//        customPinView.leftCalloutAccessoryView = myCustomImage;
//        
//        return customPinView;
//    }
}

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
            
            // use the standard mapkit pin for the annotation image
            var pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myAnnotationView")
            pinView.pinColor = .Purple
            
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
            pinView!.leftCalloutAccessoryView = getCustomAccessoryView("Albania.png") //mugIconView
            
            // Add detail button to right callout
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
}

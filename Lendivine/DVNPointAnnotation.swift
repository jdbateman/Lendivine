//
//  DVNPointAnnotation.swift
//  Lendivine
//
//  Created by john bateman on 3/20/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This class implements a custom subclass of a mapkit point annotation to carry a couple of extra pieces of information from the loan represented by the annotation object.

import UIKit
import MapKit

class DVNPointAnnotation: MKPointAnnotation {

    var annotationImage: UIImage?
    var imageID: NSNumber?
    var loan: KivaLoan?
}

//
//  LoanDetailViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/20/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LoanDetailViewController: UIViewController, MKMapViewDelegate  {

    var loan: KivaLoan?
    
//    var topViewOffset: Double? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loanImageView: UIImageView!
    @IBOutlet weak var loanFlagImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var sector: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var fundedAmount: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewToTopMarginConstraint: NSLayoutConstraint!
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        //NSLayoutConstraint(item: topView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .TopMargin, multiplier: 1.0, constant: 0.0).active = true
        
//        if let topViewOffset = topViewOffset {
//            self.topViewToTopMarginConstraint.constant = CGFloat(topViewOffset)
//        }
        
        // set the mapView delegate to this view controller
        mapView.delegate = self
        
        showPinOnMap()
    }
    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if let topViewOffset = topViewOffset {
//            self.topViewToTopMarginConstraint.constant = CGFloat(topViewOffset)
//            self.view.setNeedsDisplay()
//        }
//    }
    
    /*! hide the status bar */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func onAddToCartTap(sender: AnyObject) {
    
        guard let loan = self.loan else {
            return
        }
        
        let cart = KivaCart.sharedInstance
        if cart.KivaAddItemToCart(loan, /*loanID: loan.id,*/ donationAmount: 25.00, context: self.sharedContext) {
            
        } else {
            showLoanAlreadyInCartAlert(loan, controller: self)
        }
    }
    
    func setupView() {
        
        if let loan = self.loan {

            if let name = loan.name {
                self.name.text = name
            }
            
            if let sector = loan.sector {
                self.sector.text = sector
            }
            
            if let amount = loan.loanAmount {
                self.amount.text = "$" + amount.stringValue + " requested"
            }
            
            if let country = loan.country {
                self.country.text = country
                
                // flag
                if let uiImage = UIImage(named: country) {
                    loanFlagImageView.image = uiImage
                } else {
                    loanFlagImageView.image = UIImage(named: "United Nations")
                }
            }
            
            if let status = loan.status {
                self.status.text = "status: \(status)"
            }
            
            var fundedText = ""
            if let fundedAmount = loan.fundedAmount {
                fundedText = "$\(fundedAmount.stringValue)"
            }
            if let lenderCount = loan.lenderCount {
                fundedText = fundedText + " from \(lenderCount.stringValue) lenders"
            }
            self.fundedAmount.text = fundedText
            
            loan.getImage() {success, error, image in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.loanImageView!.image = image
                        
                        self.view.setNeedsDisplay()
                        //self.view.setNeedsLayout()
                    }
                } else  {
                    print("error retrieving loan image: \(error)")
                }
            }
        }
    }

    
    // MARK: Annotation
    
    /* Displays the current Loan on the mapView. */
    func showPinOnMap() {
        
        guard let loan = self.loan else {
            return
        }
        guard let coordinate = KivaLoan.getCoordinatesForLoan(loan) else {
            return
        }
        
        // Here we create the annotation and set its coordinate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        if let name = loan.name {
            annotation.title = "\(name)"
        }
        if let town = loan.town {
            annotation.subtitle = "\(town)"
        }
        if let country = loan.country, let subtitle = annotation.subtitle {
            annotation.subtitle = subtitle + ", \(country)"
        }
        
        // Add the annotation to an array of annotations.
        var annotations = [MKPointAnnotation]()
        annotations.append(annotation)
        
        // Add the annotations to the map.
        self.mapView.addAnnotations(annotations)
        
        // Set the center of the map.
        self.mapView.setCenterCoordinate(coordinate, animated: true)
        
        // Tell the OS that the mapView needs to be refreshed.
        self.mapView.setNeedsDisplay()
    }
    
    /*!
    @brief Display an alert controller indicating the specified loan has already been added to the cart.
    @discussion This is a convenience view function used by multiple table view cell classes in the Lendivine app.
    @param (in) loan - An attempt was made to add this loan to the cart.
    @param (in) controller - The parent view controller to host the alert.
    */
    func showLoanAlreadyInCartAlert(loan: KivaLoan, controller: UIViewController) {
        
        var message = "The selected loan has already been added to your cart."
        if let name = loan.name {
            message = "The loan requested by \(name) has already been added to your cart."
        }
        let alertController = UIAlertController(title: "Already in Cart", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            // handle OK pressed in alert controller
        }
        alertController.addAction(okAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
}

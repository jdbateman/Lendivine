//
//  LoanDetailViewController.swift
//  Lendivine
//
//  Created by john bateman on 3/20/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This view controller displays detailed information on the properties of a single loan.

import UIKit
import MapKit
import CoreData

class LoanDetailViewController: UIViewController, MKMapViewDelegate  {

    var loan: KivaLoan?
    var kivaAPI: KivaAPI?
    var showAddToCart: Bool = true
    var textAnimationTimer:NSTimer?
    var balanceDescription:String?
    var fundedString:String?
    
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loanImageView: UIImageView!
    @IBOutlet weak var loanFlagImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var country: UILabel!
    @IBOutlet weak var fundedAmount: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topViewToTopMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var useLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the kivaAPI handle
        self.kivaAPI = KivaAPI.sharedInstance
        
        setupView()
        
        // set the mapView delegate to this view controller
        mapView.delegate = self
        
        showPinOnMap()
        
        getLoanBalancesFromKiva()
    }
    
    /*! hide the status bar */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewWillAppear(animated: Bool) {
        
        textAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(5.0 , target: self, selector: "animateTextChange", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        textAnimationTimer?.invalidate()
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
           
            if let country = loan.country {
                self.country.text = country
                
                // flag
                if let uiImage = UIImage(named: country) {
                    loanFlagImageView.image = uiImage
                } else {
                    loanFlagImageView.image = UIImage(named: "United Nations")
                }
            }
         
            var fundedText = ""
            if let fundedAmount = loan.fundedAmount {
                fundedText = "$\(fundedAmount.stringValue)"
            }
            if let lenderCount = loan.lenderCount {
                fundedText = "Received " + fundedText + " from \(lenderCount.stringValue) lenders."
            }
            self.fundedAmount.text = fundedText
            self.fundedString = fundedText
            
            var statusText = ""
            if let s = loan.status {
                var cleanString = String(s.characters.map {
                    $0 == "_" ? " " : $0
                    })
                cleanString.replaceRange(cleanString.startIndex...cleanString.startIndex, with: String(cleanString[cleanString.startIndex]).capitalizedString)
                statusText = "\(cleanString)"
            }
            self.statusLabel.text = statusText
            
            var sectorText = ""
            if let s = loan.sector {
                sectorText = s
            }
            
            var amountText = ""
            if let a = loan.loanAmount {
                amountText = "$" + a.stringValue
            }

            //let descriptionText = statusText + " " + amountText + " for " + sectorText
            var description = amountText + " for " + sectorText //+ "\n" + statusText
            description.replaceRange(description.startIndex...description.startIndex, with: String(description[description.startIndex]).capitalizedString)
            descriptionLabel.text = description
            
            
            loan.getImage() {success, error, image in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.loanImageView!.image = image
                        
                        // draw border around image
                        self.loanImageView!.layer.borderColor = UIColor.whiteColor().CGColor;
                        self.loanImageView!.layer.borderWidth = 1.5
                        self.loanImageView!.layer.cornerRadius = 5.0
                        self.loanImageView!.clipsToBounds = true
                        
                        self.view.setNeedsDisplay()
                    }
                } else  {
                    print("error retrieving loan image: \(error)")
                }
            }
            
            var useText = ""
            if let u = loan.use {
                useText = u
                useText.replaceRange(useText.startIndex...useText.startIndex, with: String(useText[useText.startIndex]).capitalizedString)
            }
            useLabel.text = useText
        }
        
        addToCartButton.hidden = !showAddToCart
        bottomView.hidden = !showAddToCart
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
            // handle OK pressed in alert controller here
        }
        alertController.addAction(okAction)
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func getLoanBalancesFromKiva() {
        
        if let loanId = self.loan?.id {
            self.kivaAPI!.kivaOAuthGetLoanBalance(loanId) { success, error, balance in
                if success {
                    
                    if let balance = balance {
                        
                        self.balanceDescription =  String(format: "Repaid $%.2f of your $%.2f loan", balance.amountRepaidToLender.doubleValue, balance.amountPurchasedByLender.doubleValue)
                        
                        if let balText = self.balanceDescription {
                            self.fundedAmount.text = balText
                        }
                    }

                } else {
                    
                    print("error retrieving balances information: \(error?.localizedDescription)")
                }
            }
        }
    }
    
    func animateTextChange() {
       
        guard let funded = self.fundedString else {return}
        guard let theBalance = self.balanceDescription else {return}
        
        self.fundedAmount.fadeOutAnimation(1.5, delay: 0) {
            finished in
            
            self.fundedAmount.center = CGPoint(x: self.fundedAmount.center.x + 600, y: self.fundedAmount.center.y)
            
            if let amount = self.fundedAmount.text {
                if amount == funded {
                    self.fundedAmount.text = theBalance
                } else {
                    self.fundedAmount.text = funded
                }
            }
            
            self.fundedAmount.fadeInAnimation(1.0, delay: 0)  {finished in}
        }
     }
}

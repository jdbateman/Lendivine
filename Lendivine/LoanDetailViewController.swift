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

class LoanDetailViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate  {

    var loan: KivaLoan?
    var kivaAPI: KivaAPI?
    var showAddToCart: Bool = true
    var showBalanceInfo: Bool = false
    var textAnimationTimer:Timer?
    var balanceDescription:String?
    var fundedString:String?
    var largeImage:UIImage?
    
    @IBOutlet weak var resizeImageIvew: UIImageView!
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
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the kivaAPI handle
        self.kivaAPI = KivaAPI.sharedInstance
        
        setupView()
        
        // set the mapView delegate to this view controller
        mapView.delegate = self
        
        showPinOnMap()
        
        if showBalanceInfo == true {
            getLoanBalancesFromKiva()
        }
    }
    
    /*! hide the status bar */
    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        initTapRecognizer()
        textAnimationTimer = Timer.scheduledTimer(timeInterval: 5.0 , target: self, selector: #selector(LoanDetailViewController.animateTextChange), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        textAnimationTimer?.invalidate()
        deinitTapRecognizer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func onAddToCartTap(_ sender: AnyObject) {
    
        guard let loan = self.loan else {
            return
        }
        
        let cart = KivaCart.sharedInstance
        if cart.KivaAddItemToCart(loan, donationAmount: 25.00, context: CoreDataContext.sharedInstance().cartContext) {
            
            KivaCart.updateCartBadge(self)
            
            DispatchQueue.main.async {

                CoreDataContext.sharedInstance().saveCartContext()
            }
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
                cleanString.replaceSubrange(cleanString.startIndex...cleanString.startIndex, with: String(cleanString[cleanString.startIndex]).capitalized)
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

            var description = amountText + " for " + sectorText
            description.replaceSubrange(description.startIndex...description.startIndex, with: String(description[description.startIndex]).capitalized)
            descriptionLabel.text = description
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            activityIndicator.center = CGPoint(x: self.loanImageView.center.x - 8, y: self.loanImageView.center.y - 20)
            self.loanImageView.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            
            loan.getImage() {success, error, image in
                if success {
                    
                    DispatchQueue.main.async {
                        activityIndicator.stopAnimating()
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.loanImageView!.image = image
                        
                        // draw border around image
                        self.loanImageView!.layer.borderColor = UIColor.white.cgColor;
                        self.loanImageView!.layer.borderWidth = 1.5
                        self.loanImageView!.layer.cornerRadius = 5.0
                        self.loanImageView!.clipsToBounds = true
                        
                        // white tint on resize image
                        let resize = UIImage(named: "Resize-50")
                        let tintedResize = resize?.withRenderingMode(.alwaysTemplate)
                        self.resizeImageIvew.image = tintedResize
                        self.resizeImageIvew.tintColor = UIColor.white
                        
                        self.view.setNeedsDisplay()
                    }
                } else  {
                    if (error != nil) && ((error?.code)! == VTError.ErrorCodes.s3_FILE_DOWNLOAD_ERROR.rawValue) && (error?.localizedDescription.contains("Image download"))! {
                        LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
                    }
                    print("error retrieving loan image: \(error)")
                }
            }
            
            var useText = ""
            if let u = loan.use {
                useText = u
                useText.replaceSubrange(useText.startIndex...useText.startIndex, with: String(useText[useText.startIndex]).capitalized)
            }
            useLabel.text = useText
        }
        
        addToCartButton.isHidden = !showAddToCart
        bottomView.isHidden = !showAddToCart
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
        self.mapView.setCenter(coordinate, animated: true)
        
        // Tell the OS that the mapView needs to be refreshed.
        self.mapView.setNeedsDisplay()
    }
    
    /*!
        @brief Display an alert controller indicating the specified loan has already been added to the cart.
        @discussion This is a convenience view function used by multiple table view cell classes in the Lendivine app.
        @param (in) loan - An attempt was made to add this loan to the cart.
        @param (in) controller - The parent view controller to host the alert.
    */
    func showLoanAlreadyInCartAlert(_ loan: KivaLoan, controller: UIViewController) {
        
        var message = "The selected loan has already been added to your cart."
        if let name = loan.name {
            message = "The loan requested by \(name) has already been added to your cart."
        }
        let alertController = UIAlertController(title: "Already in Cart", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            // handle OK pressed in alert controller here
        }
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
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
                    if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.contains("offline"))! {
                        LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
                    }
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
    
    
    // MARK: Tap gesture recognizer
    
    func initTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action:#selector(LoanDetailViewController.handleSingleTap(_:)))
        
        if let tr = tapRecognizer {
            tr.numberOfTapsRequired = 1
            self.loanImageView.addGestureRecognizer(tr)
            self.loanImageView.isUserInteractionEnabled = true
        }
    }
    
    func deinitTapRecognizer() {
        self.loanImageView.removeGestureRecognizer(self.tapRecognizer!)
    }
    
    // User tapped somewhere on the image view.
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        presentImageViewController()
    }
    
    
    // MARK: Popover
    
    /* Present the LoanImageViewController as a Popover on the main thread. */
    func presentImageViewController() {
        
        if let loan = self.loan {
            
            let activityIndicator = DVNActivityIndicator()
            activityIndicator.startActivityIndicator(self.view)
            
            loan.getImage(450, height:360, square:true) {
                success, error, image in
                
                DispatchQueue.main.async {
                    activityIndicator.stopActivityIndicator()
                }
                
                
                if success {
                    DispatchQueue.main.async {
                        
                        guard let image = image else {return}
                        self.largeImage = image
                        
                        let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "LoanImageStoryboardId") as! LoanImageViewController
                        popoverContent.modalPresentationStyle = .popover
                        popoverContent.image = self.largeImage
                        if let popover = popoverContent.popoverPresentationController {
                            popover.sourceView = self.loanImageView
                            popover.sourceRect =  self.loanImageView.bounds
                            popoverContent.preferredContentSize = CGSize(width: image.size.width, height: image.size.height)
                            popover.delegate = self
                            popover.permittedArrowDirections = .up // .Any
                        }
                        
                        self.present(popoverContent, animated: true, completion: nil)
                    }
                } else  {
                    if (error != nil) && ((error?.code)! == VTError.ErrorCodes.s3_FILE_DOWNLOAD_ERROR.rawValue) && (error?.localizedDescription.contains("Image download"))! {
                        LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
                    }
                    print("error retrieving loan image: \(error)")
                }
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            return .none
    }
}

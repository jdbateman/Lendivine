//
//  LoansTableViewCell.swift
//  Lendivine
//
//  Created by john bateman on 11/12/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
// This custom table view cell is used in the LoansTableViewController to display summary information about a loan. The cell contains an AddToCart button. When selected the loan associated with the cell must be added to the cart. That is handled in this class.

import UIKit
import CoreData

class LoansTableViewCell: DVNTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!            // The total requested sum of the loan.
    @IBOutlet weak var loanImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var donatedImageView: UIImageView!
    
    var tableView: UITableView?
    
    var KivaLoanId: NSNumber?
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    @IBAction func onAddToCartButtonTap(_ sender: UIButton) {
        
         // Find the cell starting from the button.
        let button = sender 
        let contentView = button.superview!
        let cell = contentView.superview as! LoansTableViewCell
        
        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKind(of: UITableView.self) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        // Get the indexPath associated with this table cell
        let indexPath = tableView.indexPath(for: cell)
        
        // Place the loan in the cart.
        let tableViewController = tableView.dataSource as! LoansTableViewController
        let loan = tableViewController.fetchedResultsController.object(at: indexPath!) 
        
        // set default donation amount to user preference.
        var amount = 25
        let appSettings = UserDefaults.standard
        amount = appSettings.integer(forKey: "AccountDefaultDonation")
        if amount == 0 {
            amount = 25
        }

        let cart = KivaCart.sharedInstance

        if cart.KivaAddItemToCart(loan, donationAmount: amount as NSNumber?, context: CoreDataContext.sharedInstance().cartContext) {
            
            // animation:
            
            if let indexPath = indexPath {
                
                heartbeatAnimation (self.loanImageView) { success in
                
                    self.animateLoanToCart(tableView, tableView: tableView, indexPath: indexPath, loan: loan)
                    
                    if let controller = self.parentController {
                        KivaCart.updateCartBadge(controller)
                    }
                }
            }
            
            donatedImageView.isHidden = false
            
        } else {
            if let controller = self.parentController {
                showLoanAlreadyInCartAlert(loan, controller: controller)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // MARK: Animation

    func heartbeatAnimation(_ imageView: UIImageView, completion:@escaping (_ success: Bool) -> Void) {
    
        pulseAnimation(self.loanImageView) { success in
            
            var delayTimeInNanoSeconds = DispatchTime.now() + Double(Int64(0.3 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTimeInNanoSeconds) {
                
                self.pulseAnimation(self.loanImageView) { success in
                    
                    delayTimeInNanoSeconds = DispatchTime.now() + Double(Int64(0.15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTimeInNanoSeconds) {
                        
                        self.pulseAnimation(self.loanImageView) { success in
                            
                            completion(success)
                        }
                    }
                }
            }
        }
    }
    
    func pulseAnimation(_ imageView: UIImageView, completion:@escaping (_ success: Bool) -> Void) {
        
        var delayTimeInNanoSeconds = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        // shrink
        UIView.animate(withDuration: 0.4, animations: {
            let center = imageView.center
            imageView.frame.size.height -= 20
            imageView.frame.size.width -= 20
            imageView.center = center
        })
   
        //delayTimeInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        DispatchQueue.main.asyncAfter(deadline: delayTimeInNanoSeconds) {
                
            // grow
            UIView.animate(withDuration: 0.2, animations: {
                let center = imageView.center
                imageView.frame.size.height += 20
                imageView.frame.size.width += 20
                imageView.center = center
            })
            
            delayTimeInNanoSeconds = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTimeInNanoSeconds) {
                completion(true)
            }
        }
    }
    
    /*!
        @brief Animate the image belonging to the selected loan into the shopping cart on the Toolbar.
        @discussion 
        @param (in) animateOnView - The view upon which to draw the animation.
        @param (in) tableView - The table view for this view controller.
        @param (in) indexPaht - the index path of the selected cell.
        @param (in) loan - the loan associated with the selected cell.
    */
    func animateLoanToCart(/*cell: LoansTableViewCell,*/ _ animateOnView: UIView, tableView: UITableView, indexPath: IndexPath, loan: KivaLoan) {
        
        let cellImageView =  self.loanImageView
        
        // resize
        let resizedWidth = cellImageView?.frame.size.width
        let resizedHeight = cellImageView?.frame.size.height
        
        guard let cgImage = cellImageView?.image?.cgImage else {
            return
        }
        
        // copy the image
        guard let newCgIm = cgImage.copy() else {
            return
        }
        let imageCopy = UIImage(cgImage: newCgIm, scale: (cellImageView?.image!.scale)!, orientation: (cellImageView?.image!.imageOrientation)!)
        
        let imageViewCopy: UIImageView = UIImageView(image: imageCopy)
        
        let animatedObject = imageViewCopy
        
        animatedObject.frame = CGRect(x: 0, y: 0, width: resizedWidth!, height: resizedHeight!)
        
        animateOnView.addSubview(animatedObject)
        
        // Get the coordinates of the cell in the TableView's coordinate space
        let rectCellInTableViewCoords = tableView.rectForRow(at: indexPath)
        
        let rectCellInScreenCoords = rectCellInTableViewCoords.offsetBy(dx: -tableView.contentOffset.x, dy: -tableView.contentOffset.y)
        
        // screen dimensions
        let screenBounds: CGRect = UIScreen.main.bounds
        _ = screenBounds.width
        let heightOfScreen = screenBounds.height
        
        let cellOriginX = rectCellInTableViewCoords.origin.x
        let cellOriginY = rectCellInTableViewCoords.origin.y
        let cellWidth = rectCellInTableViewCoords.width
        _ = rectCellInTableViewCoords.height
        let cellToScreenBottom = heightOfScreen - rectCellInScreenCoords.origin.y
        
        // create a path that follows a bezier curve
        let path = UIBezierPath()
        let startPoint = CGPoint(x: cellOriginX + 8 + resizedWidth! / 2, y: cellOriginY + 8 + resizedHeight! / 2)
        let endPoint = CGPoint(x: cellWidth / 2, y: cellOriginY + cellToScreenBottom)
        
        // move to start point of path
        path.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        
        // move along straight line to end point of path
        // path.addLineToPoint(endPoint)

        path.addCurve(to: endPoint,
            controlPoint1: CGPoint(x: screenBounds.width * 3 / 4, y: cellOriginY + (cellToScreenBottom / 4) ),
            controlPoint2: CGPoint(x: screenBounds.width / 2, y: cellOriginY + (cellToScreenBottom) / 2 ))
        
        // create an animation object to animate our view's position
        let anim = CAKeyframeAnimation(keyPath: "position")
        
        // configure the animation to use the bezier curve
        anim.path = path.cgPath
        
        // rotate the view as it travels along the path
        anim.rotationMode = kCAAnimationRotateAuto
        anim.repeatCount = 1 // Float.infinity
        anim.duration = 1.0
        
        // Add the animation to the view
        animatedObject.layer.add(anim, forKey: "animate position along path")
        
        tableView.reloadData()
        
        let delayTimeInNanoSeconds = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTimeInNanoSeconds) {
            imageViewCopy.isHidden = true
        }
    }
    
    func animateButtonTapped(_ sender: UIView) {
        
        // create a 'tuple' (a pair or more of objects assigned to a single variable)
        var views : (frontView: UIView, backView: UIView)
        
        let cellImageView =  self.loanImageView
        let test = UIImageView()
        test.image = UIImage(named: "Donate-50")
        test.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        sender.addSubview(test)
        
        views = (frontView: cellImageView!, backView: test)
        
        // set a transition style
        let transitionOptions = UIViewAnimationOptions.transitionFlipFromLeft
        
        // with no animation block, and a completion block set to 'nil' this makes a single line of code
        UIView.transition(from: views.frontView, to: views.backView, duration: 1.0, options: transitionOptions, completion: nil)
        
    }
    
    func getImageForLoan(_ loan: KivaLoan, completion:@escaping (_ success:Bool, _ image:UIImage?, _ error:NSError?) -> Void) {
        
        loan.getImage() {success, error, image in
            if success {
                completion(true, image, nil)
            } else  {
                print("error retrieving image: \(error)")
                completion(false, nil, error)
            }
        }
    }    
}

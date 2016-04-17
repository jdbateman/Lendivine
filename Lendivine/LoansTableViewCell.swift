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
    
    var KivaLoanId: NSNumber?
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    @IBAction func onAddToCartButtonTap(sender: UIButton) {
        
         // Find the cell starting from the button.
        let button = sender 
        let contentView = button.superview!
        let cell = contentView.superview as! LoansTableViewCell
        
        // Find the tableView by walking the view hierarchy until a UITableView class is encountered.
        var view = cell.superview
        while ( (view != nil) && (view?.isKindOfClass(UITableView) == false) ) {
            view = view!.superview
        }
        let tableView: UITableView = view as! UITableView
        
        // Get the indexPath associated with this table cell
        let indexPath = tableView.indexPathForCell(cell)

        // Alternatively use the version specific code:
        //let tableView = cell.superview as! UITableView
        
        // Place the loan in the cart.
        let tableViewController = tableView.dataSource as! LoansTableViewController
        let loan = tableViewController.fetchedResultsController.objectAtIndexPath(indexPath!) as! KivaLoan
        let amount = 25  // TODO: set default donation amount to user preference.

        let cart = KivaCart.sharedInstance

        if cart.KivaAddItemToCart(loan, /*loanID: loan.id,*/ donationAmount: amount, context: self.sharedContext) {
        
            // animation:
            
            if let indexPath = indexPath {
                
                heartbeatAnimation /*pulseAnimation*/ (self.loanImageView) { success in
                
                    self.animateLoanToCart(tableView /*contentView*/, tableView: tableView, indexPath: indexPath, loan: loan)
                }
            }
            
            // Persist the KivaCartItem object we added to the Core Data shared context
            dispatch_async(dispatch_get_main_queue()) {
                CoreDataStackManager.sharedInstance().saveContext()
            }
            
            donatedImageView.hidden = false
            
        } else {
            if let controller = self.parentController {
                showLoanAlreadyInCartAlert(loan, controller: controller)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // MARK: Animation

    func heartbeatAnimation(imageView: UIImageView, completion:(success: Bool) -> Void) {
    
        pulseAnimation(self.loanImageView) { success in
            
            var delayTimeInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTimeInNanoSeconds, dispatch_get_main_queue()) {
                
                self.pulseAnimation(self.loanImageView) { success in
                    
                    delayTimeInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(0.15 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTimeInNanoSeconds, dispatch_get_main_queue()) {
                        
                        self.pulseAnimation(self.loanImageView) { success in
                            
                            completion(success: success)
                        }
                    }
                }
            }
        }
    }
    
    func pulseAnimation(imageView: UIImageView, completion:(success: Bool) -> Void) {
        
        var delayTimeInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        
        // shrink
        UIView.animateWithDuration(0.4, animations: {
            let center = imageView.center
            imageView.frame.size.height -= 20
            imageView.frame.size.width -= 20
            imageView.center = center
        })
   
        //delayTimeInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTimeInNanoSeconds, dispatch_get_main_queue()) {
                
            // grow
            UIView.animateWithDuration(0.2, animations: {
                let center = imageView.center
                imageView.frame.size.height += 20 // 60
                imageView.frame.size.width += 20 // 60
                imageView.center = center
            })
            
            delayTimeInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTimeInNanoSeconds, dispatch_get_main_queue()) {
                completion(success:true)
            }
        }
    }
    
    /*!
        @brief Animate image of selected loan into shopping cart on Toolbar.
        @discussion 
        @param (in) animateOnView - The view upon which to draw the animation.
        @param (in) tableView - The table view for this view controller.
        @param (in) indexPaht - the index path of the selected cell.
        @param (in) loan - the loan associated with the selected cell.
    */
    func animateLoanToCart(/*cell: LoansTableViewCell,*/ animateOnView: UIView, tableView: UITableView, indexPath: NSIndexPath, loan: KivaLoan) {
        
        let cellImageView =  self.loanImageView // UIImageView(image: image)
        
        // resize
        let resizedWidth = cellImageView.frame.size.width // - 60
        let resizedHeight = cellImageView.frame.size.height // - 60
        
        guard let cgImage = cellImageView.image?.CGImage else {
            return
        }
        
        // copy the image
        guard let newCgIm = CGImageCreateCopy(cgImage) else {
            return
        }
        let imageCopy = UIImage(CGImage: newCgIm, scale: cellImageView.image!.scale, orientation: cellImageView.image!.imageOrientation)
        
        //let imageCopy: UIImage = UIImage(CGImage: cgImage)
        let imageViewCopy: UIImageView = UIImageView(image: imageCopy)
        
        let animatedObject = imageViewCopy
        
        animatedObject.frame = CGRect(x: 0, y: 0, width: resizedWidth, height: resizedHeight)
        print("width, height = \(animatedObject.frame.size.width), \(animatedObject.frame.size.height)")
        
        //tableView.parentViewController?.view.addSubview(animatedObject)
        animateOnView.addSubview(animatedObject)
        
        // Get the coordinates of the cell in the TableView's coordinate space
        let rectCellInTableViewCoords = tableView.rectForRowAtIndexPath(indexPath)
        print("cellRect: \(rectCellInTableViewCoords)")
        
        let rectCellInScreenCoords = CGRectOffset(rectCellInTableViewCoords, -tableView.contentOffset.x, -tableView.contentOffset.y)
        print("cellRect with offset: \(rectCellInScreenCoords)")
        
        // screen dimensions
        let screenBounds: CGRect = UIScreen.mainScreen().bounds
        _ = screenBounds.width
        let heightOfScreen = screenBounds.height
        
        let cellOriginX = rectCellInTableViewCoords.origin.x
        let cellOriginY = rectCellInTableViewCoords.origin.y
        let cellWidth = rectCellInTableViewCoords.width
        _ = rectCellInTableViewCoords.height
        let cellToScreenBottom = heightOfScreen - rectCellInScreenCoords.origin.y
        
        // create a path that follows a bezier curve
        let path = UIBezierPath()
        let startPoint = CGPoint(x: cellOriginX + 8 + resizedWidth / 2, y: cellOriginY + 8 + resizedHeight / 2)
        let endPoint = CGPoint(x: cellWidth / 2, y: cellOriginY + cellToScreenBottom)
        
        // move to start point of path
        path.moveToPoint(CGPoint(x: startPoint.x, y: startPoint.y))
        
        // move along straight line to end point of path
        // path.addLineToPoint(endPoint)

        path.addCurveToPoint(endPoint,
            controlPoint1: CGPoint(x: screenBounds.width * 3 / 4, y: cellOriginY + (cellToScreenBottom / 4) ),
            controlPoint2: CGPoint(x: screenBounds.width / 2, y: cellOriginY + (cellToScreenBottom) / 2 ))
        
        // create an animation object to animate our view's position
        let anim = CAKeyframeAnimation(keyPath: "position")
        
        // configure the animation to use the bezier curve
        anim.path = path.CGPath
        
        // rotate the view as it travels along the path
        anim.rotationMode = kCAAnimationRotateAuto
        anim.repeatCount = 1 // Float.infinity
        anim.duration = 1.0
        
        // Add the animation to the view
        animatedObject.layer.addAnimation(anim, forKey: "animate position along path")
        
        tableView.reloadData()
        
        let delayTimeInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTimeInNanoSeconds, dispatch_get_main_queue()) {
            imageViewCopy.hidden = true
        }
    }
    
    func animateButtonTapped(sender: UIView) {
        
        // create a 'tuple' (a pair or more of objects assigned to a single variable)
        var views : (frontView: UIView, backView: UIView)
        
        let cellImageView =  self.loanImageView
        let test = UIImageView()
        test.image = UIImage(named: "Donate-50")
        test.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        sender.addSubview(test)
        
        views = (frontView: cellImageView, backView: test)
        
        // set a transition style
        let transitionOptions = UIViewAnimationOptions.TransitionFlipFromLeft
        
        // with no animation block, and a completion block set to 'nil' this makes a single line of code
        UIView.transitionFromView(views.frontView, toView: views.backView, duration: 1.0, options: transitionOptions, completion: nil)
        
    }
    
    func getImageForLoan(loan: KivaLoan, completion:(success:Bool, image:UIImage?, error:NSError?) -> Void) {
        
        loan.getImage() {success, error, image in
            if success {
                completion(success:true, image:image, error:nil)
            } else  {
                print("error retrieving image: \(error)")
                completion(success:false, image:nil, error:error)
            }
        }
    }
}

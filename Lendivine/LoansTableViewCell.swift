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

class LoansTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel! // loan amount
    @IBOutlet weak var loanImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    
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
//        let persistedLoan = KivaLoan(fromLoan: loan, context: self.sharedContext)
        let cart = KivaCart.sharedInstance
        cart.KivaAddItemToCart(loan, loanID: loan.id, donationAmount: amount, context: self.sharedContext)
//        cart.KivaAddItemToCart(loan.id, donationAmount: amount, context: self.sharedContext)
        
        self.animateLoanToCart(cell, view: contentView, tableView: tableView, loan: loan)

        // Persist the KivaCartItem object we added to the Core Data shared context
        dispatch_async(dispatch_get_main_queue()) {
            CoreDataStackManager.sharedInstance().saveContext()
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

    func animateLoanToCart(cell: LoansTableViewCell, view: UIView, tableView: UITableView, loan: KivaLoan) {
        

        //let square = UIView()
//        guard let square = cell.imageView else {
//            return
//        }
        guard let imageView = cell.imageView else {
            return
        }
// this worked when stubbed with an image from .xcassets
//        guard let image = getImageForLoan(loan) else {
//            return
//        }
        
        // TODO - getImageForloan is not needed. remove and just use the self.loanImageView property

        getImageForLoan(loan) { success, image, error in
            
            if success {
                
                let cellImageView =  self.loanImageView // UIImageView(image: image)
                
                // resize
                let resizedWidth = cellImageView.frame.size.width / 2
                let resizedHeight = cellImageView.frame.size.height / 2
                cellImageView.frame = CGRectMake(0, 0, resizedWidth, resizedHeight)
                cellImageView.center = imageView.superview!.center
                
                // TODO: trying here to make a copy of the original cell image view and animate the copy
//                var newCellImageView: UIImageView?
//                let newCgIm = CGImageCreateCopy(cellImageView.image?.CGImage)
//                let newImage = UIImage(CGImage: newCgIm!, scale: newCellImageView!.image!.scale, orientation: imageView.image!.imageOrientation)
//                newCellImageView = UIImageView(image: newImage)
                
                
                let square = /*newCellImageView!*/ cellImageView
                
//                TODO START HERE
//                getCellsCoordinatesIn tableview controller's view. Try animating everything wrt the table VC's view.
                
                
                //square.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
                square.frame = CGRect(x: 10, y: 10, width: self.loanImageView.frame.size.width, height: self.loanImageView.frame.size.height)
//                square.frame = CGRect(x: 10, y: 10, width: cellImageView.frame.size.width, height: cellImageView.frame.size.height)
                print("width, height = \(self.loanImageView.frame.size.width), \(self.loanImageView.frame.size.height)")
                //square.backgroundColor = UIColor.redColor()
                //view.addSubview(square)
                tableView.addSubview(square)
                
                //        TODO:
                //        getPositionOfCellinTableView()
                //        getSizeOfImage()
                
                let visibleRect: CGRect = tableView.convertRect(view.bounds, toView:tableView)
                print("convert contentView rect \(view.bounds) to tableView rect \(visibleRect)")
                
                // create a path that follows a bezier curve
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: cellImageView.frame.size.width / 2, y: cellImageView.frame.size.height / 2))
                path.addCurveToPoint(CGPoint(x: 290, y: 600), controlPoint1: CGPoint(x: 120, y: 37), controlPoint2: CGPoint(x: 290, y: 11))
                
                // create an animation object to animate our view's position
                let anim = CAKeyframeAnimation(keyPath: "position")
                
                // configure the animation to use the bezier curve
                anim.path = path.CGPath
                
                // rotate the view as it travels along the path
                anim.rotationMode = kCAAnimationRotateAuto
                anim.repeatCount = 1 // Float.infinity
                anim.duration = 1.5
                
                // Add the animation to the view
                square.layer.addAnimation(anim, forKey: "animate position along path")
            }
        }
        
//        let cellImageView = UIImageView(image: image)
//        let square = cellImageView
//        
//        //square.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
//        square.frame = CGRect(x: 10, y: 10, width: cellImageView.frame.size.width, height: cellImageView.frame.size.height)
//        print("width, height = \(cellImageView.frame.size.width), \(cellImageView.frame.size.height)")
//        //square.backgroundColor = UIColor.redColor()
//        //view.addSubview(square)
//        tableView.addSubview(square)
//        
////        TODO:
////        getPositionOfCellinTableView()
////        getSizeOfImage()
//        
//        let visibleRect: CGRect = tableView.convertRect(tableView.bounds, toView:tableView)
//        
//        // create a path that follows a bezier curve
//        let path = UIBezierPath()
//        path.moveToPoint(CGPoint(x: 80, y: 80))
//        path.addCurveToPoint(CGPoint(x: 290, y: 600), controlPoint1: CGPoint(x: 120, y: 37), controlPoint2: CGPoint(x: 290, y: 11))
//
//        // create an animation object to animate our view's position
//        let anim = CAKeyframeAnimation(keyPath: "position")
//        
//        // configure the animation to use the bezier curve
//        anim.path = path.CGPath
//        
//        // rotate the view as it travels along the path
//        anim.rotationMode = kCAAnimationRotateAuto
//        anim.repeatCount = Float.infinity
//        anim.duration = 1.5
//        
//        // Add the animation to the view
//        square.layer.addAnimation(anim, forKey: "animate position along path")
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

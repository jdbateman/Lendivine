//
//  AccountViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/17/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This view controller displays the user's account information such as name, email, lender Id, balance, and account image.
//  Account data is synced from Kiva.org through the Kiva REST API, and persisted or updated to core data.
//  The user's preferred donation amount is persisted to NSUserDefaults.
//  The user's image is saved to disk. (Kiva does not have an interface to update the account image on the server yet.)

import UIKit
import CoreData
import OAuthSwift

/* A custom NSNotification that indicates any updated country data from the web service is now available in core data. */
let logoutNotificationKey = "com.lendivine.accountViewController.logout"

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var lenderIDLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var defaultDonationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var calendarImageView: UIImageView!
    @IBOutlet weak var repaymentLabel: UILabel!
    
    var kivaAPI: KivaAPI?
    
    var _account: KivaAccount?
    
    var loanRepaymentSchedule:[KivaRepayment]?
    
    var _repaymentIndex:Int?
    
    var textAnimationTimer:NSTimer?
    
    var accountImageId:NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the kivaAPI handle
        self.kivaAPI = KivaAPI.sharedInstance
        
        setupView()
        
        populateAccountData()
    }

    override func viewWillAppear(animated: Bool) {
        textAnimationTimer = NSTimer.scheduledTimerWithTimeInterval(4.0 , target: self, selector: #selector(AccountViewController.animateTextChange), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        textAnimationTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        
        _repaymentIndex = 0
        
        setupDefaultAvatarImage()
        
        // camera button
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            cameraButton.enabled = true
        } else {
            cameraButton.enabled = false
        }
    }
    
    func updateViewWithAccountData() {
        
        guard let account = _account else {return}
        
        if let name = account.name {
            self.nameLabel.text = name
        }
        
        if let email = account.email {
            self.emailLabel.text = email
        }
        
        if let balance = account.balance {
            self.balanceLabel.text = balance
        }
        
        if let lenderId = account.lenderId {
            self.lenderIDLabel.text = lenderId
        }
        
        if let imageId = accountImageId {
            
            let activityIndicator = DVNActivityIndicator()
            activityIndicator.startActivityIndicator(avatarImageView)
            
            let accountImage = KivaImage(imageId: imageId)
            accountImage.getImage() {
                success, error, image in
                if success {
                    if let image = image {
                        self.updateAvatarImageInView(image)
                    }
                }
                activityIndicator.stopActivityIndicator()
            }
        }
    }
    
    // MARK: Avatar image
    
    func setAccountImage(newImage:UIImage) {
        
        updateAvatarImageInView(newImage)
        
        // save the new image to disk
        if let account = _account {
            account.deleteAccountImageFileFromFileSystem()
            account.saveAccountImage(newImage)
        }
    }
    
    /*! Set and style the avatar image */
    func updateAvatarImageInView(image: UIImage) {
        
        avatarImageView.image = image
        
        // bordered with grey outlined circle, scale to fill
        avatarImageView.contentMode = .ScaleAspectFill
        avatarImageView.layer.cornerRadius = 90
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.blackColor()
    }
    
    /*! Display default avatar image. */
    func setupDefaultAvatarImage() {
    
        // white tint
        let avatar = UIImage(named: "User-100")
        let tintedAvatar = avatar?.imageWithRenderingMode(.AlwaysTemplate)
        avatarImageView.image = tintedAvatar
        avatarImageView.tintColor = UIColor.whiteColor()
        
        // bordered with grey outlined circle
        avatarImageView.layer.cornerRadius = 90
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.blackColor()
    }
    
    
    // MARK: Actions
    
    // pick an image from the camera
    @IBAction func onCameraButton(sender: AnyObject) {
        self.presentImagePicker(UIImagePickerControllerSourceType.Camera)
    }
    
    // pick an image from the photo album
    @IBAction func onAlbumButton(sender: AnyObject) {
        self.presentImagePicker(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func onLogoutButton(sender: AnyObject) {
        
        // reset any user defaults
        writeDefaultDonation(25)
        
        // reset login state
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.loggedIn = false
        
        showKivaLogoutInExternalBrowser()
    }
    
    /*! Launch external Safari web browser to Kiva logout page to log the user out of the Kiva service. */
    func showKivaLogoutInExternalBrowser() {
        dispatch_async(dispatch_get_main_queue()) {
            self.presentLoginScreenAfterDelay(0.1)
        }
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.kiva.org/logout")!)
        }
    }

    /*! Present the Login screen after the specified number of seconds elapse. */
    func presentLoginScreenAfterDelay(seconds:Double) {
        
        let delayTimeInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTimeInNanoSeconds, dispatch_get_main_queue()) {
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            // present login controller as the root view controller
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let rootController:LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
            let navigationController = UINavigationController(rootViewController: rootController)
            appDelegate.window?.rootViewController = navigationController
        }
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /*! The value changed on the Default Donation segmented control. */
    @IBAction func defaultDonationChangedAction(sender: AnyObject) {
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            writeDefaultDonation(25)
        case 1:
            writeDefaultDonation(50)
        case 2:
            writeDefaultDonation(100)
        default:
            break; 
        }
    }
    
    func setDefaultDonation(amount:Int) {
        
        switch amount
        {
        case 25:
            defaultDonationSegmentedControl.selectedSegmentIndex = 0
        case 50:
            defaultDonationSegmentedControl.selectedSegmentIndex = 1
        case 100:
            defaultDonationSegmentedControl.selectedSegmentIndex = 2
        default:
            defaultDonationSegmentedControl.selectedSegmentIndex = 0
            break;
        }
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let selectedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            setAccountImage(selectedImage)
        } else if let selectedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            setAccountImage(selectedImage)
        } else {
            return
        }
        
        // dismiss the image picker view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // dismiss the image picker view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: Populate Account Data
    
    func populateAccountData() {

        getRepaymentScheduleForAllLoans()
        
        syncAccountFromKivaToCoreData()
        
        // Initi default donation from NSUserDefaults
        let defaultDonation = readDefaultDonation()
        setDefaultDonation(defaultDonation)
    }
    
    func getRepaymentScheduleForAllLoans() {
        
        self.kivaAPI!.kivaOAuthGetUserExpectedRepayment() { success, error, expectedRepayments in
            
            if success {
             
                if let repayments = expectedRepayments {
                    
                    let sortedRepayments = repayments.sort { $0.repaymentDate < $1.repaymentDate }
                    self.loanRepaymentSchedule = sortedRepayments
                }
            } else {
                self.checkForInternetConnectivityError(error)
                print("error retrieving repayment information: \(error?.localizedDescription)")
            }
        }
    }
    
    func syncAccountFromKivaToCoreData() {
    
        getAccountFromKiva() {
            success, error, accountData in
            
            if success {
                // persist the data from kiva as a KivaAccount object in core data, & save the returned instance of the KivaAccount object in this object.
                self._account = self.persistAccountDataToCoreData(accountData)
                
                self.updateViewWithAccountData()
            }
        }
    }
    
    /*! Retrieve account data from Kiva.org. */
    func getAccountFromKiva(completionHandler: (success: Bool, error: NSError?, accountData: [String:AnyObject]?) -> Void) {
        let activityIndicator = DVNActivityIndicator()
        activityIndicator.startActivityIndicator(self.view)
        // account name and lender ID
        kivaAPI!.kivaOAuthGetUserAccount() {
            success, error, kivaAccount in

            var account = [String:AnyObject]()
            
            if success {
                if let firstName = kivaAccount?.firstName {
                    if let lastName = kivaAccount?.lastName {
                        account[KivaAccount.InitKeys.name] = firstName + " " + lastName
                    }
                }
                
                if let lenderID = kivaAccount?.lenderID {
                    account[KivaAccount.InitKeys.lenderId] = lenderID
                }
                
                // email
                self.kivaAPI!.kivaOAuthGetUserEmail(){ success, error, email in
                    if success {
                        if let email = email {
                            account[KivaAccount.InitKeys.email] = email
                        }
                        
                        // balance
                        self.kivaAPI!.kivaOAuthGetUserBalance(){ success, error, balance in
                            if success {
                                if let balance = balance {
                                    account[KivaAccount.InitKeys.balance] = balance
                                }
                                
                                // Retrieve the lender to get the imageID for this account.
                                self.kivaAPI!.kivaOAuthGetLender() { success, error, lender in
                                    if success {
                                        
                                        if let mylender = lender {
                                            
                                            let lenderImageId = mylender.imageID
                                            self.accountImageId = lenderImageId
                                            let accountImage = KivaImage(imageId: lenderImageId)
                                            
                                            accountImage.getImage() {
                                                success, error, image in
                                                
                                                if success {
                                                    dispatch_async(dispatch_get_main_queue()) {
                                                        self.avatarImageView.image = image
                                                        if let image = image {
                                                            self.setAccountImage(image)
                                                        }
                                                    }
                                                } else  {
                                                    print("error retrieving image: \(error)")
                                                }
                                            }
                                            
                                        }
                                        activityIndicator.stopActivityIndicator()
                                        completionHandler(success:true, error:nil, accountData: account)
                                    } else {
                                        self.checkForInternetConnectivityError(error)
                                        print("error retrieving lender: \(error?.localizedDescription)")
                                        activityIndicator.stopActivityIndicator()
                                        completionHandler(success:false, error:error, accountData: account)
                                    }
                                
                                }
                            } else {
                                self.checkForInternetConnectivityError(error)
                                print("error retrieving user balance: \(error?.localizedDescription)")
                                activityIndicator.stopActivityIndicator()
                                completionHandler(success:false, error:error, accountData: account)
                            }
                        }
                        
                    } else {
                        self.checkForInternetConnectivityError(error)
                        print("error retrieving user email: \(error?.localizedDescription)")
                        activityIndicator.stopActivityIndicator()
                        completionHandler(success:false, error:error, accountData: account)
                    }
                }
                
            } else {
                self.checkForInternetConnectivityError(error)
                print("error retrieving user account: \(error?.localizedDescription)")
                activityIndicator.stopActivityIndicator()
                completionHandler(success:false, error:error, accountData: account)
            }
        }
    }
    
    /*! Upload account data to Kiva.org */
    func accountToKiva() {
        // Unfortunately Kiva.org does not currently support this functionality.
    }
    
    /*! Persist the account properties as an KivaAccount object to core data on disk, and save an instance of the object in this object's properties. */
    func persistAccountDataToCoreData(account:[String:AnyObject]?) -> KivaAccount? {
        
        guard let account = account else {return nil}
        guard let lenderId = account[KivaAccount.InitKeys.lenderId] as? String else {return nil}
        
        let newAccount = KivaAccount(dictionary: account, context: CoreDataContext.sharedInstance().accountContext)
                
        // Determine if this account already exist in core data.

        let fetchRequest = NSFetchRequest(entityName: "KivaAccount")
        fetchRequest.predicate = NSPredicate(format: "lenderId = %@", lenderId)

        
        do {
            let fetchResults = try CoreDataContext.sharedInstance().accountContext.executeFetchRequest(fetchRequest)
            
            // success ...
            if fetchResults.count != 0 {
                
                // A match! Update the existing core data object that has this same lenderId.
                
                let managedObject = fetchResults[0]
                
                if let name = account[KivaAccount.InitKeys.name] {
                    managedObject.setValue(name, forKey: KivaAccount.InitKeys.name)
                }
                if let email = account[KivaAccount.InitKeys.email] {
                    managedObject.setValue(email, forKey: KivaAccount.InitKeys.email)
                }
                if let balance = account[KivaAccount.InitKeys.balance] {
                    managedObject.setValue(balance, forKey: KivaAccount.InitKeys.balance)
                }
                
                CoreDataContext.sharedInstance().saveAccountContext()
                
            } else {
                // no matches to exiting core data objects on disk. save the new object in core data.
                CoreDataContext.sharedInstance().saveAccountContext()
            }
            
        } catch let error as NSError {
            
            // failure...don't save the new object
            print("Fetch failed: \(error.localizedDescription). Aborting save of account object to core data.")
        }
        
        return newAccount
    }
    
    
    // MARK: Persist defaults
    
    func writeDefaultDonation(amount:Int) {
        
        let appSettings = NSUserDefaults.standardUserDefaults()
        appSettings.setValue(amount, forKey: "AccountDefaultDonation")
    }
    
    func readDefaultDonation() -> Int {
        
        let appSettings = NSUserDefaults.standardUserDefaults()
        let amount = appSettings.integerForKey("AccountDefaultDonation")
        return amount
    }
    
    
    // MARK: Animation
    
    func animateTextChange() {

        guard let loanRepaymentSchedule = self.loanRepaymentSchedule where loanRepaymentSchedule.count > 0 else {return}
        guard let repaymentIndex = _repaymentIndex else {return}
        let repaymentAmount = loanRepaymentSchedule[repaymentIndex].userRepayments
        let repaymentDate = loanRepaymentSchedule[repaymentIndex].repaymentDate
        _repaymentIndex = (repaymentIndex < loanRepaymentSchedule.count - 1) ? repaymentIndex + 1 : 0

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        guard let date = dateFormatter.dateFromString(repaymentDate) else {return}
        
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        let convertedDate = dateFormatter.stringFromDate(date)
        
        self.repaymentLabel.fadeOutAnimation(1.0, delay: 0) {
            finished in
            
            self.repaymentLabel.center = CGPoint(x: self.repaymentLabel.center.x + 600, y: self.repaymentLabel.center.y)
            
            self.repaymentLabel.text = "Repayment of $\(repaymentAmount) on \(convertedDate)"
            
            self.repaymentLabel.fadeInAnimation(0.8, delay: 0)  {finished in}
        }
    }
    
    // MARK: Notification
    
    /*! Post a notification indicating logout was initiated. */
    func postLogoutNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(logoutNotificationKey, object: self)
    }
    
    // MARK: Helper
    
    func checkForInternetConnectivityError(error: NSError?) {
        if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.containsString("offline"))! {
            LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
        }
    }
}

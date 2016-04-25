//
//  AccountViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/17/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This view controller displays the user's account information such as name, email, lender Id, and balance.
//  Account data is synced from Kiva.org through the Kiva REST API, and persisted or updated to core data.
//  The user's preferred donation amount is persisted to NSUserDefaults.
//  The user's image is saved to disk. (Kiva does not have an interface to acquire or update the account image yet.)

import UIKit
import CoreData

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var lenderIDLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    @IBOutlet weak var defaultDonationSegmentedControl: UISegmentedControl!
    
    var kivaAPI: KivaAPI?
    
    /* The main core data managed object context. This context will be persisted. */
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    var _account: KivaAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the kivaAPI handle
        self.kivaAPI = KivaAPI.sharedInstance
        
        setupView()
        
        populateAccountData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        
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
        
        if let image = account.getImage() {
            self.avatarImageView.image = image
        }
    }
    
    /*! Display default avatar image. */
    func setupDefaultAvatarImage() {
    
        // white tint
        let avatar = UIImage(named: "User-100")
        let tintedAvatar = avatar?.imageWithRenderingMode(.AlwaysTemplate)
        avatarImageView.image = tintedAvatar
        avatarImageView.tintColor = UIColor.whiteColor()
        
        // bordered with grey outlined circle
        avatarImageView.layer.cornerRadius = 100
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
        
        // present login controller as the root view controller
        let storyboard = UIStoryboard (name: "Main", bundle: nil)
        let rootController:LoginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginStoryboardID") as! LoginViewController
        let navigationController = UINavigationController(rootViewController: rootController)
        appDelegate.window?.rootViewController = navigationController
    }
    
    func presentImagePicker(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func setAccountImage(newImage:UIImage) {
        
        // update the view with the new image
        avatarImageView.image = newImage
        avatarImageView.contentMode = .ScaleAspectFill
        avatarImageView.layer.cornerRadius = 100
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.blackColor()
        
        // save the new image to disk
        if let account = _account {
            account.saveImage(newImage)
        }
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
    
    
    // Make KivaAPI calls to retrieve and render the user's kiva account information.
//    func populateAccountData() {
//        // account name and lender ID
//        kivaAPI!.kivaOAuthGetUserAccount() {success, error, account in
//            if success {
//                if let firstName = account?.firstName {
//                    if let lastName = account?.lastName {
//                        self.nameLabel.text = firstName + " " + lastName
//                    }
//                }
//                if let lenderID = account?.lenderID {
//                    self.lenderIDLabel.text = lenderID
//                }
//                if let accountId = account?.id {
//                    
//                    self.getImage(accountId) {
//                        success, error, image in
//                        if success {
//                            if let image = image {
//                                self.avatarImageView.image = image
//                            }
//                        }
//                    }
//                }
//            } else {
//                print("error retrieving user account: \(error?.localizedDescription)")
//            }
//        }
//        
//        // email
//        kivaAPI!.kivaOAuthGetUserEmail(){ success, error, email in
//            if success {
//                if let email = email {
//                    self.emailLabel.text = email
//                }
//            } else {
//                print("error retrieving user email: \(error?.localizedDescription)")
//            }
//        }
//        
//        // balance
//        kivaAPI!.kivaOAuthGetUserBalance(){ success, error, balance in
//            if success {
//                if let balance = balance {
//                    self.balanceLabel.text = balance
//                }
//            } else {
//                print("error retrieving user balance: \(error?.localizedDescription)")
//            }
//        }
//        
//        // Default donation
//        let defaultDonation = readDefaultDonation()
//        setDefaultDonation(defaultDonation)
//    }
    
    
    // Data
    
    func populateAccountData() {
        
        syncAccountFromKivaToCoreData()
        
        // Initi default donation from NSUserDefaults
        let defaultDonation = readDefaultDonation()
        setDefaultDonation(defaultDonation)
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
        
        // account name and lender ID
        kivaAPI!.kivaOAuthGetUserAccount() {
            success, error, kivaAccount in

            var account = [String:AnyObject]()
            
            if success {
                if let firstName = kivaAccount?.firstName {
                    if let lastName = kivaAccount?.lastName {
//                        self.nameLabel.text = firstName + " " + lastName
                        account[KivaAccount.InitKeys.name] = firstName + " " + lastName
                    }
                }
                
                if let lenderID = kivaAccount?.lenderID {
//                    self.lenderIDLabel.text = lenderID
                    account[KivaAccount.InitKeys.lenderId] = lenderID
                }
                
//                if let accountId = kivaAccount?.id {
//                    
//                    // TODO
////                    self.getImage(accountId) {
////                        success, error, image in
////                        if success {
////                            if let image = image {
////                                self.avatarImageView.image = image
////                            }
////                        }
////                    }
//                }
                
                // email
                self.kivaAPI!.kivaOAuthGetUserEmail(){ success, error, email in
                    if success {
                        if let email = email {
//                            self.emailLabel.text = email
                            account[KivaAccount.InitKeys.email] = email
                        }
                        
                        // balance
                        self.kivaAPI!.kivaOAuthGetUserBalance(){ success, error, balance in
                            if success {
                                if let balance = balance {
//                                    self.balanceLabel.text = balance
                                    account[KivaAccount.InitKeys.balance] = balance
                                }
                                
                                completionHandler(success:true, error:nil, accountData: account)
                                
                            } else {
                                print("error retrieving user balance: \(error?.localizedDescription)")
                                completionHandler(success:false, error:error, accountData: account)
                            }
                        }
                        
                    } else {
                        print("error retrieving user email: \(error?.localizedDescription)")
                        completionHandler(success:false, error:error, accountData: account)
                    }
                }
                
            } else {
                print("error retrieving user account: \(error?.localizedDescription)")
                completionHandler(success:false, error:error, accountData: account)
            }
        }
//        
//
//        
//
//        
//        return account
//        
//        
//        // persist to core data on disk
//        if let account = account {
//            let newAccount = KivaAccount.init(dictionary: account, context: sharedContext)
//            CoreDataStackManager.sharedInstance().saveContext()
//            print("new account: %@", account)
//        }
    }
    
    /*! Upload account data to Kiva.org */
    func accountToKiva() {
        // Unfortunately Kiva.org dos not currently support this functionality.
    }
    
    /*! Persist the account properties as an KivaAccount object to core data on disk, and save an instance of the object in this object's properties. */
    func persistAccountDataToCoreData(account:[String:AnyObject]?) -> KivaAccount? {
        
        guard let account = account else {return nil}
        guard let lenderId = account[KivaAccount.InitKeys.lenderId] as? String else {return nil}
        
        let newAccount = KivaAccount(dictionary: account, context: sharedContext)
                
        // Determine if this account already exist in core data.

        let fetchRequest = NSFetchRequest(entityName: "KivaAccount")
        fetchRequest.predicate = NSPredicate(format: "lenderId = %@", lenderId)

        
        do {
            let fetchResults = try sharedContext.executeFetchRequest(fetchRequest)
            
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
                
                CoreDataStackManager.sharedInstance().saveContext()
                
                print("updated existing account object in core data: %@", account)
                
            } else {
                // no matches to exiting core data objects on disk. save the new object in core data.
                CoreDataStackManager.sharedInstance().saveContext()
                print("new account object saved to core data: %@", account)
            }
            
        } catch let error as NSError {
            
            // failure...don't save the new object
            print("Fetch failed: \(error.localizedDescription). Aborting save of account object to core data.")
        }
        
        return newAccount
    }
    
    
    // MARK: Image
    
//    /*!
//        @brief Return a String representing the url of the image identified by kivaImageID
//        @param kivaImageID The Kiva image identifier.
//        @return A String representing the url where the image can be downloaded, or nil in case of an error or invalid identifier.
//        example image url: http://www.kiva.org/img/s50/5c43752887e05aabbf90934177d9eacc.jpg
//    */
//    func getImageUrl(kivaImageID: NSNumber?) -> String? {
//        if let kivaImageID = kivaImageID {
//            let imageUrlString = String(format:"http://www.kiva.org/img/s50/%@.jpg", kivaImageID.stringValue)
//            return imageUrlString
//        }
//        return nil
//    }
//    
//    /*
//        @brief Acquire the UIImage for this Loan object.
//        @discussion The image is retrieved using the following sequence:
//            1. todo - cache
//            2. todo - filesystem
//            3. download the image from self.imageUrl.
//        @param completion (in)
//        @param success (out) - true if image successfully acquired, else false.
//        @param error (out) - NSError object if an error occurred, else nil.
//        @param image (out) - the retrieved UIImage. May be nil if no image was found, or if an error occurred.
//    */
//    func getImage(kivaImageID: NSNumber, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void ) {
//        
//        let imageUrl = getImageUrl(kivaImageID)
//
//        // Load the image from the server asynchronously on a background queue.
//        if let url = imageUrl {
//            self.dowloadImageFrom(url) { success, error, theImage in
//                if success {
//                    if let _ = theImage {
//                        //self.cacheImageAndWriteToFile(theImage)
//                    }
//                    print("image downloaded from server")
//                    completion(success: true, error: nil, image: theImage)
//                    return
//                } else {
//                    // The download failed. Retry the download once.
//                    self.dowloadImageFrom(url) { success, error, theImage in
//                        if success {
//                            if let _ = theImage {
//                                //self.cacheImageAndWriteToFile(theImage)
//                            }
//                            print("image downloaded from server")
//                            completion(success: true, error: nil, image: theImage)
//                            return
//                        } else {
//                            let vtError = VTError(errorString: "Image download from Kiva service failed.", errorCode: VTError.ErrorCodes.S3_FILE_DOWNLOAD_ERROR)
//                            completion(success: false, error: vtError.error, image: nil)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    /* Download the image identified by imageUrlString in a background thread, convert it to a UIImage object, and return the object. */
//    func dowloadImageFrom(imageUrlString: String?, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void) {
//        
//        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
//        dispatch_async(backgroundQueue, {
//            // get the binary image data
//            let imageURL:NSURL? = NSURL(string: imageUrlString!)
//            if let imageData = NSData(contentsOfURL: imageURL!) {
//                
//                // Convert the image data to a UIImage object and append to the array to be returned.
//                if let picture = UIImage(data: imageData) {
//                    completion(success: true, error: nil, image: picture)
//                }
//                else {
//                    let vtError = VTError(errorString: "Cannot convert image data.", errorCode: VTError.ErrorCodes.IMAGE_CONVERSION_ERROR)
//                    completion(success: false, error: vtError.error, image: nil)
//                }
//                
//            } else {
//                let vtError = VTError(errorString: "Image does not exist at \(imageURL)", errorCode: VTError.ErrorCodes.FILE_NOT_FOUND_ERROR)
//                completion(success: false, error: vtError.error, image: nil)
//            }
//        })
//    }
    
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
}

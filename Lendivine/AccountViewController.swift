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
import SafariServices

/* A custom NSNotification that indicates any updated country data from the web service is now available in core data. */
let logoutNotificationKey = "com.lendivine.accountViewController.logout"

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSafariViewControllerDelegate {

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
    
    var textAnimationTimer:Timer?
    
    var accountImageId:NSNumber?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the kivaAPI handle
        self.kivaAPI = KivaAPI.sharedInstance
        
        setupView()
        
        populateAccountData()
    }

    override func viewWillAppear(_ animated: Bool) {
        textAnimationTimer = Timer.scheduledTimer(timeInterval: 4.0 , target: self, selector: #selector(AccountViewController.animateTextChange), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            cameraButton.isEnabled = true
        } else {
            cameraButton.isEnabled = false
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
    
    func setAccountImage(_ newImage:UIImage) {
        
        updateAvatarImageInView(newImage)
        
        // save the new image to disk
        if let account = _account {
            account.deleteAccountImageFileFromFileSystem()
            account.saveAccountImage(newImage)
        }
    }
    
    /*! Set and style the avatar image */
    func updateAvatarImageInView(_ image: UIImage) {
        
        avatarImageView.image = image
        
        // bordered with grey outlined circle, scale to fill
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 90
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.darkGray.cgColor
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.black
    }
    
    /*! Display default avatar image. */
    func setupDefaultAvatarImage() {
    
        // white tint
        let avatar = UIImage(named: "User-100")
        let tintedAvatar = avatar?.withRenderingMode(.alwaysTemplate)
        avatarImageView.image = tintedAvatar
        avatarImageView.tintColor = UIColor.white
        
        // bordered with grey outlined circle
        avatarImageView.layer.cornerRadius = 90
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.darkGray.cgColor
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.black
    }
    
    
    // MARK: Actions
    
    // pick an image from the camera
    @IBAction func onCameraButton(_ sender: AnyObject) {
        self.presentImagePicker(UIImagePickerControllerSourceType.camera)
    }
    
    // pick an image from the photo album
    @IBAction func onAlbumButton(_ sender: AnyObject) {
        self.presentImagePicker(UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        
        // reset any user defaults
        writeDefaultDonation(25)
        
        // reset login state
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.loggedIn = false
        
        logoutWithSFSafariViewController()
        //showKivaLogoutInExternalBrowser()
    }
    
    /*! Launch external Safari web browser to Kiva logout page to log the user out of the Kiva service. */
    func showKivaLogoutInExternalBrowser() {
        DispatchQueue.main.async {
            self.presentLoginScreenAfterDelay(0.1)
        }
        DispatchQueue.main.async {
            UIApplication.shared.openURL(URL(string: "https://www.kiva.org/logout")!)
        }
    }
    
    func logoutWithSFSafariViewController() {
        
// re-enable this line to automatically hide the Kiva post-logout page.
//        dispatch_async(dispatch_get_main_queue()) {
//            self.presentLoginScreenAfterDelay(0.1)
//        }
        DispatchQueue.main.async {
            if let logoutURL = URL(string: "https://www.kiva.org/logout") {
                let safariVC = SFSafariViewController(url: logoutURL)
                safariVC.delegate = self
                self.present(safariVC, animated: true, completion: nil)
            }
        }
    }

    /*! Present the Login screen after the specified number of seconds elapse. */
    func presentLoginScreenAfterDelay(_ seconds:Double) {
        
        let delayTimeInNanoSeconds = DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: delayTimeInNanoSeconds) {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            // present login controller as the root view controller
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let rootController:LoginViewController = storyboard.instantiateViewController(withIdentifier: "LoginStoryboardID") as! LoginViewController
            let navigationController = UINavigationController(rootViewController: rootController)
            appDelegate.window?.rootViewController = navigationController
        }
    }
    
    func presentImagePicker(_ sourceType: UIImagePickerControllerSourceType) {
        let imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    /*! The value changed on the Default Donation segmented control. */
    @IBAction func defaultDonationChangedAction(_ sender: AnyObject) {
        
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
    
    func setDefaultDonation(_ amount:Int) {
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let selectedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            setAccountImage(selectedImage)
        } else if let selectedImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            setAccountImage(selectedImage)
        } else {
            return
        }
        
        // dismiss the image picker view controller
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // dismiss the image picker view controller
        dismiss(animated: true, completion: nil)
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
                    
                    let sortedRepayments = repayments.sorted { $0.repaymentDate < $1.repaymentDate }
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
    func getAccountFromKiva(_ completionHandler: @escaping (_ success: Bool, _ error: NSError?, _ accountData: [String:AnyObject]?) -> Void) {
        let activityIndicator = DVNActivityIndicator()
        activityIndicator.startActivityIndicator(self.view)
        // account name and lender ID
        kivaAPI!.kivaOAuthGetUserAccount() {
            success, error, kivaAccount in

            var account = [String:AnyObject]()
            
            if success {
                if let firstName = kivaAccount?.firstName {
                    if let lastName = kivaAccount?.lastName {
                        account[KivaAccount.InitKeys.name] = firstName + " " + lastName as AnyObject?
                    }
                }
                
                if let lenderID = kivaAccount?.lenderID {
                    account[KivaAccount.InitKeys.lenderId] = lenderID as AnyObject?
                }
                
                // email
                self.kivaAPI!.kivaOAuthGetUserEmail(){ success, error, email in
                    if success {
                        if let email = email {
                            account[KivaAccount.InitKeys.email] = email as AnyObject?
                        }
                        
                        // balance
                        self.kivaAPI!.kivaOAuthGetUserBalance(){ success, error, balance in
                            if success {
                                if let balance = balance {
                                    account[KivaAccount.InitKeys.balance] = balance as AnyObject?
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
                                                    DispatchQueue.main.async {
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
                                        completionHandler(true, nil, account)
                                    } else {
                                        self.checkForInternetConnectivityError(error)
                                        print("error retrieving lender: \(error?.localizedDescription)")
                                        activityIndicator.stopActivityIndicator()
                                        completionHandler(false, error, account)
                                    }
                                
                                }
                            } else {
                                self.checkForInternetConnectivityError(error)
                                print("error retrieving user balance: \(error?.localizedDescription)")
                                activityIndicator.stopActivityIndicator()
                                completionHandler(false, error, account)
                            }
                        }
                        
                    } else {
                        self.checkForInternetConnectivityError(error)
                        print("error retrieving user email: \(error?.localizedDescription)")
                        activityIndicator.stopActivityIndicator()
                        completionHandler(false, error, account)
                    }
                }
                
            } else {
                self.checkForInternetConnectivityError(error)
                print("error retrieving user account: \(error?.localizedDescription)")
                activityIndicator.stopActivityIndicator()
                completionHandler(false, error, account)
            }
        }
    }
    
    /*! Upload account data to Kiva.org */
    func accountToKiva() {
        // Unfortunately Kiva.org does not currently support this functionality.
    }
    
    /*! Persist the account properties as an KivaAccount object to core data on disk, and save an instance of the object in this object's properties. */
    func persistAccountDataToCoreData(_ account:[String:AnyObject]?) -> KivaAccount? {
        
        guard let account = account else {return nil}
        guard let lenderId = account[KivaAccount.InitKeys.lenderId] as? String else {return nil}
        
        let newAccount = KivaAccount(dictionary: account, context: CoreDataContext.sharedInstance().accountContext)
                
        // Determine if this account already exist in core data.

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "KivaAccount")
        fetchRequest.predicate = NSPredicate(format: "lenderId = %@", lenderId)

        
        do {
            let fetchResults = try CoreDataContext.sharedInstance().accountContext.fetch(fetchRequest)
            
            // success ...
            if fetchResults.count != 0 {
                
                // A match! Update the existing core data object that has this same lenderId.
                
                let managedObject = fetchResults[0]
                
                if let name = account[KivaAccount.InitKeys.name] {
                    (managedObject as AnyObject).setValue(name, forKey: KivaAccount.InitKeys.name)
                }
                if let email = account[KivaAccount.InitKeys.email] {
                    (managedObject as AnyObject).setValue(email, forKey: KivaAccount.InitKeys.email)
                }
                if let balance = account[KivaAccount.InitKeys.balance] {
                    (managedObject as AnyObject).setValue(balance, forKey: KivaAccount.InitKeys.balance)
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
    
    func writeDefaultDonation(_ amount:Int) {
        
        let appSettings = UserDefaults.standard
        appSettings.setValue(amount, forKey: "AccountDefaultDonation")
    }
    
    func readDefaultDonation() -> Int {
        
        let appSettings = UserDefaults.standard
        let amount = appSettings.integer(forKey: "AccountDefaultDonation")
        return amount
    }
    
    
    // MARK: Animation
    
    func animateTextChange() {

        guard let loanRepaymentSchedule = self.loanRepaymentSchedule, loanRepaymentSchedule.count > 0 else {return}
        guard let repaymentIndex = _repaymentIndex else {return}
        let repaymentAmount = loanRepaymentSchedule[repaymentIndex].userRepayments
        let repaymentDate = loanRepaymentSchedule[repaymentIndex].repaymentDate
        _repaymentIndex = (repaymentIndex < loanRepaymentSchedule.count - 1) ? repaymentIndex + 1 : 0

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        guard let date = dateFormatter.date(from: repaymentDate) else {return}
        
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.long
        let convertedDate = dateFormatter.string(from: date)
        
        self.repaymentLabel.fadeOutAnimation(1.0, delay: 0) {
            finished in
            
            self.repaymentLabel.center = CGPoint(x: self.repaymentLabel.center.x + 600, y: self.repaymentLabel.center.y)
            
            self.repaymentLabel.text = "Repayment of $\(repaymentAmount) on \(convertedDate)"
            
            self.repaymentLabel.fadeInAnimation(0.8, delay: 0)  {finished in}
        }
    }
    
    // MARK: - SFSafariViewControllerDelegate
    
    // Called on "Done" button on SFSafariViewController. Presents the Login screen.
    @available(iOS 9.0, *)
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        // Note: If automatic hiding of the Kiva page is enable above in logoutWithSFSafariViewController() then this code can be removed.
        DispatchQueue.main.async {
            self.presentLoginScreenAfterDelay(0.1)
        }
    }
    
    // MARK: Notification
    
    /*! Post a notification indicating logout was initiated. */
    func postLogoutNotification() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: logoutNotificationKey), object: self)
    }
    
    // MARK: Helper
    
    func checkForInternetConnectivityError(_ error: NSError?) {
        if (error != nil) && ((error?.code)! == -1009) && (error?.localizedDescription.contains("offline"))! {
            LDAlert(viewController: self).displayErrorAlertView("No Internet Connection", message: (error?.localizedDescription)!)
        }
    }
}

//
//  AccountViewController.swift
//  Lendivine
//
//  Created by john bateman on 11/17/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This view controller displays the user's account information such as name, email, lender Id, and balance.

import UIKit

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var lenderIDLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    
    var kivaAPI: KivaAPI?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the kivaAPI handle
        self.kivaAPI = KivaAPI.sharedInstance
        
        setupAvatarImage()
        
        // camera button
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            cameraButton.enabled = true
        } else {
            cameraButton.enabled = false
        }
        
        populateAccountData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*! Display default avatar image. */
    func setupAvatarImage() {
    
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
    
    func presentImagePicker(var sourceType: UIImagePickerControllerSourceType) {
        var imagePicker: UIImagePickerController = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func setAccountImage(newImage:UIImage) {
        
        avatarImageView.image = newImage
        avatarImageView.contentMode = .ScaleAspectFill
        avatarImageView.layer.cornerRadius = 100
        avatarImageView.layer.borderWidth = 2
        avatarImageView.layer.borderColor = UIColor.darkGrayColor().CGColor
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor.blackColor()
        
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        //if let info = editingInfo {
//            if let image = editingInfo![UIImagePickerControllerOriginalImage] as? UIImage {
//                avatarImageView.contentMode = .ScaleAspectFit
//                avatarImageView.image = image
//            }
//        //}
        
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
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            avatarImageView.contentMode = .ScaleAspectFit
//            avatarImageView.image = image
//        }
//        // dismiss the image picker view controller
//        dismissViewControllerAnimated(true, completion: nil)
//    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // dismiss the image picker view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Make KivaAPI calls to retrieve and render the user's kiva account information.
    func populateAccountData() {
        // account name and lender ID
        kivaAPI!.kivaOAuthGetUserAccount() {success, error, account in
            if success {
                if let firstName = account?.firstName {
                    if let lastName = account?.lastName {
                        self.nameLabel.text = firstName + " " + lastName
                    }
                }
                if let lenderID = account?.lenderID {
                    self.lenderIDLabel.text = lenderID
                }
                if let accountId = account?.id {
                    
                    self.getImage(accountId) {
                        success, error, image in
                        if success {
                            if let image = image {
                                self.avatarImageView.image = image
                            }
                        }
                    }
                }
            } else {
                print("error retrieving user account: \(error?.localizedDescription)")
            }
        }
        
        // email
        kivaAPI!.kivaOAuthGetUserEmail(){ success, error, email in
            if success {
                if let email = email {
                    self.emailLabel.text = email
                }
            } else {
                print("error retrieving user email: \(error?.localizedDescription)")
            }
        }
        
        // balance
        kivaAPI!.kivaOAuthGetUserBalance(){ success, error, balance in
            if success {
                if let balance = balance {
                    self.balanceLabel.text = balance
                }
            } else {
                print("error retrieving user balance: \(error?.localizedDescription)")
            }
        }
    }
    
    
    // MARK: Image
    
    /*!
    @brief Return a String representing the url of the image identified by kivaImageID
    @param kivaImageID The Kiva image identifier.
    @return A String representing the url where the image can be downloaded, or nil in case of an error or invalid identifier.
    example image url: http://www.kiva.org/img/s50/5c43752887e05aabbf90934177d9eacc.jpg
    */
    func getImageUrl(kivaImageID: NSNumber?) -> String? {
        if let kivaImageID = kivaImageID {
            let imageUrlString = String(format:"http://www.kiva.org/img/s50/%@.jpg", kivaImageID.stringValue)
            return imageUrlString
        }
        return nil
    }
    
    /*
        @brief Acquire the UIImage for this Loan object.
        @discussion The image is retrieved using the following sequence:
            1. todo - cache
            2. todo - filesystem
            3. download the image from self.imageUrl.
        @param completion (in)
        @param success (out) - true if image successfully acquired, else false.
        @param error (out) - NSError object if an error occurred, else nil.
        @param image (out) - the retrieved UIImage. May be nil if no image was found, or if an error occurred.
    */
    func getImage(kivaImageID: NSNumber, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void ) {
        
        let imageUrl = getImageUrl(kivaImageID)
        
        // Try loading the image from the image cache.
//        if let url = imageUrl {
//            if let theImage: UIImage = NSCache.sharedInstance.objectForKey(url) as? UIImage {
//                print("image loaded from cache")
//                completion(success: true, error: nil, image: theImage)
//                return
//            }
//        }

        // Load the image from the server asynchronously on a background queue.
        if let url = imageUrl {
            self.dowloadImageFrom(url) { success, error, theImage in
                if success {
                    if let theImage = theImage {
                        //self.cacheImageAndWriteToFile(theImage)
                    }
                    print("image downloaded from server")
                    completion(success: true, error: nil, image: theImage)
                    return
                } else {
                    // The download failed. Retry the download once.
                    self.dowloadImageFrom(url) { success, error, theImage in
                        if success {
                            if let theImage = theImage {
                                //self.cacheImageAndWriteToFile(theImage)
                            }
                            print("image downloaded from server")
                            completion(success: true, error: nil, image: theImage)
                            return
                        } else {
                            let vtError = VTError(errorString: "Image download from Kiva service failed.", errorCode: VTError.ErrorCodes.S3_FILE_DOWNLOAD_ERROR)
                            completion(success: false, error: vtError.error, image: nil)
                        }
                    }
                }
            }
        }
    }
    
    /* Download the image identified by imageUrlString in a background thread, convert it to a UIImage object, and return the object. */
    func dowloadImageFrom(imageUrlString: String?, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void) {
        
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue, {
            // get the binary image data
            let imageURL:NSURL? = NSURL(string: imageUrlString!)
            if let imageData = NSData(contentsOfURL: imageURL!) {
                
                // Convert the image data to a UIImage object and append to the array to be returned.
                if let picture = UIImage(data: imageData) {
                    completion(success: true, error: nil, image: picture)
                }
                else {
                    let vtError = VTError(errorString: "Cannot convert image data.", errorCode: VTError.ErrorCodes.IMAGE_CONVERSION_ERROR)
                    completion(success: false, error: vtError.error, image: nil)
                }
                
            } else {
                let vtError = VTError(errorString: "Image does not exist at \(imageURL)", errorCode: VTError.ErrorCodes.FILE_NOT_FOUND_ERROR)
                completion(success: false, error: vtError.error, image: nil)
            }
        })
    }
}

//
//  KivaImage.swift
//  Lendivine
//
//  Created by john bateman on 4/26/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import Foundation
import UIKit

class KivaImage {
    
    struct InitKeys {
        static let imageID: String = "id"
    }

    var imageID: NSNumber? // default: -1
    
    init(imageId: NSNumber?) {
        imageID = imageId
    }
    
    /*
    @brief Acquire the UIImage for this Loan object.
    @discussion The image is retrieved using the following sequence:
    1. cache
    2. filesystem
    3. download the image from self.imageUrl.
    @param completion (in)
    @param success (out) - true if image successfully acquired, else false.
    @param error (out) - NSError object if an error occurred, else nil.
    @param image (out) - the retrieved UIImage. May be nil if no image was found, or if an error occurred.
    */
    func getImage(completion: (success: Bool, error: NSError?, image: UIImage?) -> Void ) {
        
        let imageUrl = getImageUrl(self.imageID)
        
        // Try loading the image from the image cache.
        if let url = imageUrl {
            if let theImage: UIImage = NSCache.sharedInstance.objectForKey(url) as? UIImage {
                print("image loaded from cache")
                completion(success: true, error: nil, image: theImage)
                return
            }
        }
        
        // Try loading the data from the file system.
        if let imageID = self.imageID {
            if let image = getImageFromFileSystem(imageID.stringValue) {
                print("image loaded from file system")
                
                // Cache the image in memory.
                self.cacheImage(image)
                
                completion(success: true, error: nil, image: image)
                return
            }
        }
        
        // Load the image from the server asynchronously on a background queue.
        if let url = imageUrl {
            self.dowloadImageFrom(url) { success, error, theImage in
                if success {
                    if let theImage = theImage {
                        self.cacheImageAndWriteToFile(theImage)
                    }
                    print("image downloaded from server")
                    completion(success: true, error: nil, image: theImage)
                    return
                } else {
                    // The download failed. Retry the download once.
                    self.dowloadImageFrom(url) { success, error, theImage in
                        if success {
                            if let theImage = theImage {
                                self.cacheImageAndWriteToFile(theImage)
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
    func getKivaImage(kivaImageID: NSNumber?, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void) {
        if let kivaImageID = kivaImageID {
            let imageUrlString = String(format:"http://www.kiva.org/img/w200h200/%@.jpg", kivaImageID.stringValue)
            //            func dowloadImageFrom(imageUrlString: String?, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void) {
            
            let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
            dispatch_async(backgroundQueue, {
                // get the binary image data
                let imageURL = NSURL(string: imageUrlString)
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
            //            }
        }
    }
    
    /*!
    @brief Return a String representing the url of the image identified by kivaImageID
    @param kivaImageID The Kiva image identifier.
    @return A String representing the url where the image can be downloaded, or nil in case of an error or invalide identifier.
    */
    func getImageUrl(kivaImageID: NSNumber?) -> String? {
        if let kivaImageID = kivaImageID {
            let imageUrlString = String(format:"http://www.kiva.org/img/w200h200/%@.jpg", kivaImageID.stringValue)
            return imageUrlString
        }
        return nil
    }
    
    /* Save image to a file with the name filename on the filesystem in the Documents directory. */
    func saveImageToFileSystem(filename: String, image: UIImage?) {
        if let image = image {
            let imageData = UIImageJPEGRepresentation(image, 1)
            let path = pathForImageFileWith(filename)
            if let path = path {
                if let imageData = imageData {
                    imageData.writeToFile(path, atomically: true)
                }
            }
        }
    }
    
    /* Load the data from filename and return as a UIImage object. */
    func getImageFromFileSystem(filename: String) -> UIImage? {
        let path = pathForImageFileWith(filename)
        if let path = path {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                let imageData = NSFileManager.defaultManager().contentsAtPath(path)
                if let imageData = imageData {
                    let image = UIImage(data: imageData)
                    return image
                }
            }
        }
        return nil
    }
    
    /* Return the path to filename in the app’s Documents directory */
    func pathForImageFileWith(filename: String) -> String? {
        // the Documents directory's path is returned as a one-element array.
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let pathArray = [dirPath, filename]
        let fileURL =  NSURL.fileURLWithPathComponents(pathArray)!
        return fileURL.path
    }
    
    /* Save the image data to the image cache in memory. */
    func cacheImage(theImage: UIImage) {
        
        // Ensure access of the managed object happpens on the main queue
        dispatch_async(dispatch_get_main_queue()) {
            let imageUrl = self.getImageUrl(self.imageID)
            if let url = imageUrl {
                let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
                dispatch_async(backgroundQueue, {
                    NSCache.sharedInstance.setObject(theImage, forKey: url)
                })
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
    
    /* Save the image to the local cache and file system. */
    func cacheImageAndWriteToFile(theImage: UIImage) {
        
        // Ensure access of the managed object happpens on the main queue
        dispatch_async(dispatch_get_main_queue()) {
            if let imageID = self.imageID {
                // save the image data to the file system
                let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
                dispatch_async(backgroundQueue, {
                    //if let imageID = self.imageID {
                    self.saveImageToFileSystem(imageID.stringValue, image: theImage)
                    //}
                })
            }
        }
        
        // save the image to the image cache in memory
        self.cacheImage(theImage)
    }
}

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
    Image sizes are maximums
    @param width (in) - desired width of image
    @param height (in) - desired height of image
    @param square (in) - If true then a square image will be requested from Kiva using the width parameter for the dimension of a side.
    @param completion (in)
    @param success (out) - true if image successfully acquired, else false.
    @param error (out) - NSError object if an error occurred, else nil.
    @param image (out) - the retrieved UIImage. May be nil if no image was found, or if an error occurred.
    */
    func getImage(width:Int = kDefaultImageWidth, height:Int = kDefaultImageHeight, square:Bool = false, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void ) {
        
        let imageUrl = makeImageUrl(self.imageID, width:width, height:height, square:square)
        
        // Try loading the image from the image cache.
        if let url = imageUrl {

            if let theImage: UIImage = NSCache.sharedInstance.objectForKey(url) as? UIImage {
                completion(success: true, error: nil, image: theImage)
                return
            }
        }
        
        // Try loading the data from the file system.
        if let imageID = self.imageID {
            let imageFilename = makeImageFilename(imageID, width:width, height:height)
            if let image = getImageFromFileSystem(imageFilename) {
                
                // Cache the image in memory.
                self.cacheImage(image, square:square)
                
                completion(success: true, error: nil, image: image)
                return
            }
        }
        
        // Load the image from the server asynchronously on a background queue.
        if let url = imageUrl {
            self.dowloadImageFrom(url) {
                success, error, theImage in
                if success {
                    if let theImage = theImage {
                        self.cacheImageAndWriteToFile(theImage, width:width, height:height, square: square)
                    }
                    completion(success: true, error: nil, image: theImage)
                    return
                } else {
                    // The download failed. Retry the download once.
                    self.dowloadImageFrom(url) { success, error, theImage in
                        if success {
                            if let theImage = theImage {
                                self.cacheImageAndWriteToFile(theImage, width:width, height:height, square: square)
                            }
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
    func getKivaImage(kivaImageID: NSNumber?, square:Bool = false, completion: (success: Bool, error: NSError?, image: UIImage?) -> Void) {
        
        if let kivaImageID = kivaImageID {
            
            // todo: pass image width and height into this method and use it in this call the enable support for non200x200 image sizes.
            guard let imageUrlString = self.makeImageUrl(kivaImageID, width: kDefaultImageWidth, height: kDefaultImageHeight, square:square) else {return}
            
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
    @dicussion Kiva.org returns an image with max size bounded by width and height.
    @param kivaImageID The Kiva image identifier.
    @param width desired width of the image.
    @param height desired height of the image.
    @param square if true then width is used to build a URL for requesting a square image from kiva.
    @return A String representing the url where the image can be downloaded, or nil in case of an error or invalide identifier.
    */
    func makeImageUrl(kivaImageID: NSNumber?, width:Int = 200, height:Int = 200, square:Bool = false) -> String? {
        
        if let kivaImageID = kivaImageID {
            
            var imageUrlString:String?
            
            if square == true {
                imageUrlString = makeSquareImageUrl(kivaImageID, side:width)
            } else {
                imageUrlString = String(format:"http://www.kiva.org/img/w%dh%d/%@.jpg", width, height, kivaImageID.stringValue)
            }
            
            return imageUrlString
        }
        
        return nil
    }
    
    /*! Build a URL used to request a square image from kiva for the given image Id with a dimenstion = side. */
    func makeSquareImageUrl(kivaImageID: NSNumber?, side:Int = 300) -> String? {
        if let kivaImageID = kivaImageID {
            let imageUrlString = String(format:"http://www.kiva.org/img/s%d/%@.jpg", side, kivaImageID.stringValue)
            return imageUrlString
        }
        return nil
    }
    
    /*! Return a String representing the filename of the image on disk. The filename consists of the <imageId> + w<width> + h<height> +.jpg.
    Example output: "123456w340h460.jpg"
    */
    func makeImageFilename(imageId:NSNumber, width:Int = 200, height:Int = 200) -> String {
        let imageFilename = String(format: "%@w%dh%d.jpg", imageId.stringValue, width, height)
        return imageFilename
    }
    
    /*!
    @brief Save image to a file with the name filename on the filesystem in the Documents directory.
    @discussion It is recommended to construct the filename using the makeImageFilename helper method.
    */
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
    
    /*
    @brief Save the image data to the image cache in memory.
    @param The imageID, width, and height are used to construct a url that is used as the key to cache the image.
    */
    func cacheImage(theImage: UIImage, width:Int = kDefaultImageWidth, height:Int = kDefaultImageHeight, square:Bool = false) {
        
        // Ensure access of the managed object happpens on the main queue
        dispatch_async(dispatch_get_main_queue()) {
            let imageUrl = self.makeImageUrl(self.imageID, width:width, height:height, square:square)
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
    func cacheImageAndWriteToFile(theImage: UIImage, width:Int = kDefaultImageWidth, height:Int = kDefaultImageHeight, square:Bool = false) {
        
        // Ensure access of the managed object happpens on the main queue
        dispatch_async(dispatch_get_main_queue()) {
            if let imageID = self.imageID {
                // save the image data to the file system
                let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
                dispatch_async(backgroundQueue, {
                    let imageFilename = self.makeImageFilename(imageID, width:width, height:height)
                    self.saveImageToFileSystem(imageFilename, image: theImage)
                })
            }
        }
        
        // save the image to the image cache in memory
        self.cacheImage(theImage, square:square)
    }
}

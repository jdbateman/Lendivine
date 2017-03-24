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
    func getImage(_ width:Int = kDefaultImageWidth, height:Int = kDefaultImageHeight, square:Bool = false, completion: @escaping (_ success: Bool, _ error: NSError?, _ image: UIImage?) -> Void ) {
        
        let imageUrl = makeImageUrl(self.imageID, width:width, height:height, square:square)
        
        // Try loading the image from the image cache.
        if let url = imageUrl {

            if let theImage: UIImage = DVNCache.sharedInstance.object(forKey: url as AnyObject) as? UIImage {
                completion(true, nil, theImage)
                return
            }
        }
        
        // Try loading the data from the file system.
        if let imageID = self.imageID {
            let imageFilename = makeImageFilename(imageID, width:width, height:height)
            if let image = getImageFromFileSystem(imageFilename) {
                
                // Cache the image in memory.
                self.cacheImage(image, square:square)
                
                completion(true, nil, image)
                return
            }
        }
        
        // Load the image from the server asynchronously on a background queue.
        if let url = imageUrl {
            self.downloadImageFrom(url, withTimeout:30) {
                success, error, theImage in
                if success {
                    if let theImage = theImage {
                        self.cacheImageAndWriteToFile(theImage, width:width, height:height, square: square)
                    }
                    completion(true, nil, theImage)
                    return
                } else {
                    // The download failed. Retry the download once.
                    self.downloadImageFrom(url, withTimeout:30) { success, error, theImage in
                        if success {
                            if let theImage = theImage {
                                self.cacheImageAndWriteToFile(theImage, width:width, height:height, square: square)
                            }
                            completion(true, nil, theImage)
                            return
                        } else {
                            let vtError = VTError(errorString: "Image download from Kiva service failed.", errorCode: VTError.ErrorCodes.s3_FILE_DOWNLOAD_ERROR)
                            completion(false, vtError.error, nil)
                        }
                    }
                }
            }
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
    func makeImageUrl(_ kivaImageID: NSNumber?, width:Int = 200, height:Int = 200, square:Bool = false) -> String? {
        
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
    func makeSquareImageUrl(_ kivaImageID: NSNumber?, side:Int = 300) -> String? {
        if let kivaImageID = kivaImageID {
            let imageUrlString = String(format:"http://www.kiva.org/img/s%d/%@.jpg", side, kivaImageID.stringValue)
            return imageUrlString
        }
        return nil
    }
    
    /*! Return a String representing the filename of the image on disk. The filename consists of the <imageId> + w<width> + h<height> +.jpg.
    Example output: "123456w340h460.jpg"
    */
    func makeImageFilename(_ imageId:NSNumber, width:Int = 200, height:Int = 200) -> String {
        let imageFilename = String(format: "%@w%dh%d.jpg", imageId.stringValue, width, height)
        return imageFilename
    }
    
    /*!
    @brief Save image to a file with the name filename on the filesystem in the Documents directory.
    @discussion It is recommended to construct the filename using the makeImageFilename helper method.
    */
    func saveImageToFileSystem(_ filename: String, image: UIImage?) {
        if let image = image {
            let imageData = UIImageJPEGRepresentation(image, 1)
            let path = pathForImageFileWith(filename)
            if let path = path {
                if let imageData = imageData {
                    try? imageData.write(to: URL(fileURLWithPath: path), options: [.atomic])
                }
            }
        }
    }
    
    /* Load the data from filename and return as a UIImage object. */
    func getImageFromFileSystem(_ filename: String) -> UIImage? {
        let path = pathForImageFileWith(filename)
        if let path = path {
            if FileManager.default.fileExists(atPath: path) {
                let imageData = FileManager.default.contents(atPath: path)
                if let imageData = imageData {
                    let image = UIImage(data: imageData)
                    return image
                }
            }
        }
        return nil
    }
    
    /* Return the path to filename in the app’s Documents directory */
    func pathForImageFileWith(_ filename: String) -> String? {
        // the Documents directory's path is returned as a one-element array.
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pathArray = [dirPath, filename]
        let fileURL =  NSURL.fileURL(withPathComponents: pathArray)!
        return fileURL.path
    }
    
    /*
    @brief Save the image data to the image cache in memory.
    @param The imageID, width, and height are used to construct a url that is used as the key to cache the image.
    */
    func cacheImage(_ theImage: UIImage, width:Int = kDefaultImageWidth, height:Int = kDefaultImageHeight, square:Bool = false) {
        
        // Ensure access of the managed object happpens on the main queue
        DispatchQueue.main.async {
            let imageUrl = self.makeImageUrl(self.imageID, width:width, height:height, square:square)
            if let url = imageUrl {
                let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                backgroundQueue.async(execute: {
                    DVNCache.sharedInstance.setObject(theImage, forKey: url as AnyObject)
                })
            }
        }
    }
    
    /* Download the image identified by imageUrlString in a background thread, convert it to a UIImage object, and return the object. */
    func downloadImageFrom(_ imageUrlString: String?, completion: @escaping (_ success: Bool, _ error: NSError?, _ image: UIImage?) -> Void) {
        
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        backgroundQueue.async(execute: {
            // get the binary image data
            let imageURL:URL? = URL(string: imageUrlString!)
            if let imageData = try? Data(contentsOf: imageURL!) {
                
                // Convert the image data to a UIImage object and append to the array to be returned.
                if let picture = UIImage(data: imageData) {
                    completion(true, nil, picture)
                }
                else {
                    let vtError = VTError(errorString: "Cannot convert image data.", errorCode: VTError.ErrorCodes.image_CONVERSION_ERROR)
                    completion(false, vtError.error, nil)
                }
                
            } else {
                let vtError = VTError(errorString: "Unable to download image at \(imageURL)", errorCode: VTError.ErrorCodes.file_NOT_FOUND_ERROR)
                completion(false, vtError.error, nil)
            }
        })
    }
    
    /*! Download image asynchronously in background queue with the specified timeout in seconds. */
    func downloadImageFrom(_ imageUrlString: String?, withTimeout timeout:Double, completion:@escaping (_ success:Bool, _ error:NSError?, _ image:UIImage?)->Void) {
        
        guard let imageUrlString = imageUrlString else {
            let error = NSError(domain: "KivaImage.imageDownloadError", code: 1018, userInfo: [NSLocalizedDescriptionKey: "missing country code"])
            completion(false, error, nil)
            return
        }
        
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        backgroundQueue.async {
            
            let url: URL = URL(string: imageUrlString)!
            //let imageDownloadRequest: NSMutableURLRequest = NSMutableURLRequest(url: url)
            var imageDownloadRequest = URLRequest(url: url)     // todo:swift3
            let session = URLSession.shared
            
            imageDownloadRequest.httpMethod = "GET"
            imageDownloadRequest.timeoutInterval = timeout
            
            let task = session.dataTask(with: imageDownloadRequest, completionHandler: {
                imageData, response, error -> Void in
                
                if error == nil {
                    // Convert the image data to a UIImage object
                    if let imageData = imageData, let picture = UIImage(data: imageData) {
                        completion(true, nil, picture)
                    }
                    else {
                        completion(false, error as NSError?, nil)
                    }
                } else {
                    completion(false, error as NSError?, nil)
                }
            })
            
            task.resume()
        }
    }
    
    /* Save the image to the local cache and file system. */
    func cacheImageAndWriteToFile(_ theImage: UIImage, width:Int = kDefaultImageWidth, height:Int = kDefaultImageHeight, square:Bool = false) {
        
        // Ensure access of the managed object happpens on the main queue
        DispatchQueue.main.async {
            if let imageID = self.imageID {
                // save the image data to the file system
                let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
                backgroundQueue.async(execute: {
                    let imageFilename = self.makeImageFilename(imageID, width:width, height:height)
                    self.saveImageToFileSystem(imageFilename, image: theImage)
                })
            }
        }
        
        // save the image to the image cache in memory
        self.cacheImage(theImage, square:square)
    }
}

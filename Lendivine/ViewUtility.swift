//
//  ViewUtility.swift
//  Lendivine
//
//  Created by john bateman on 11/18/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//

import Foundation
import UIKit

class ViewUtility {
    
    // Draw text onto the backingImage and return the composite image as a UIImage.
    static func createImageFromText(text: NSString, backingImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup text font
        let font: UIFont = UIFont(name: "Helvetica Bold", size: 14)!
        let color: UIColor = UIColor.whiteColor()
        let fontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
        ]
 
        // Setup the image context with the backingImage.
        UIGraphicsBeginImageContext(backingImage.size)

        // Draw the image into a rectangle whose size is that of the image itself.
        backingImage.drawInRect(CGRectMake(0, 0, backingImage.size.width, backingImage.size.height))
        
        // Create a rectangle the size of the image and draw the text into it.
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, backingImage.size.width, backingImage.size.height)
        text.drawInRect(rect, withAttributes: fontAttributes)
        
        
        let fontAttributes2 = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.blackColor(),
        ]
        let rect2: CGRect = CGRectMake(atPoint.x - 1, atPoint.y - 1, backingImage.size.width, backingImage.size.height)
        text.drawInRect(rect2, withAttributes: fontAttributes2)
        
        // Make a new image from the image context upon which we've drawn.
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
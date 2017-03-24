//
//  ViewUtility.swift
//  Lendivine
//
//  Created by john bateman on 11/18/15.
//  Copyright © 2015 John Bateman. All rights reserved.
//
//  This class implements utility functions used in the view.

import Foundation
import UIKit

class ViewUtility {
    
    // Draw text onto the backingImage and return the composite image as a UIImage.
    static func createImageFromText(_ text: NSString, backingImage: UIImage, atPoint:CGPoint)->UIImage{
        
        let backingWidth = backingImage.size.width
        let backingHeight = backingImage.size.height
        
        // Setup text font
        let font: UIFont = UIFont(name: "Helvetica Bold", size: 18)!
        let color: UIColor = UIColor.black
        let fontAttributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
        ]
 
        // Setup the image context with the backingImage.
        UIGraphicsBeginImageContext(backingImage.size)

        // Draw the image into a rectangle whose size is that of the image itself.
        backingImage.draw(in: CGRect(x: 0, y: 0, width: backingWidth, height: backingHeight))
        
        // Create a rectangle the size of the image and draw the text into it.
        let x = atPoint.x - 6
        let rect: CGRect = CGRect(x: x, y: atPoint.y, width: backingWidth, height: backingHeight)
        text.draw(in: rect, withAttributes: fontAttributes)
        
        
        let fontAttributes2 = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.green,
        ]
        let rect2: CGRect = CGRect(x: x - 2, y: atPoint.y - 2, width: backingWidth, height: backingHeight)
        text.draw(in: rect2, withAttributes: fontAttributes2)
        
        // Make a new image from the image context upon which we've drawn.
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }

}

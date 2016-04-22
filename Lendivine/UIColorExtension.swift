//
//  UIColorExtension.swift
//  Lendivine
//
//  Created by john bateman on 4/4/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
// Acknowledgement: Thanks Bloudermilk on stack overflow for the idea to extend UIColor with a convenience initializer to create a UIColor from an rgb value, and Nate Cook for the original example.

import Foundation
import UIKit

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
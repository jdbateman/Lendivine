//
//  LoanImageViewController.swift
//  Lendivine
//
//  Created by john bateman on 5/6/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//
//  This view class implements a view controller that displays a single image.

import UIKit

class LoanImageViewController: UIViewController {
    
    var image: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.bounds.size.width = image!.size.width
        imageView.bounds.size.height = image!.size.height
        
        if let image = image {
            imageView.image = image
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


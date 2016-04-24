//
//  AcknowledgementsViewController.swift
//  Lendivine
//
//  Created by john bateman on 4/22/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit

class AcknowledgementsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var acknowledgementsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        
        setupScroll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        let point = CGPointMake(0, self.scrollView.contentOffset.y)
        scrollView.setContentOffset(point, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentSize.height = acknowledgementsLabel.bounds.size.height
    }
    
    func setupView() {
        
        let artists = ["Georgia Osinga", "Jolan Soens", "Erin Standley", "Gregor Črešnar", "Veronika Geertsema König", "Joel Olson"]
        let artistsText = artists.joinWithSeparator("\n")
        let oAuthAck = "OAuthSwift framework:\nCopyright © 2016\nhttps://github.com/OAuthSwift/OAuthSwift\n"
    
        let otherArtwork = " Flag Images from http://365icon.com/icon-styles/ethnic/classic2/, Earth icon from http://www.iconbeast.com/free/ "
        
        let mitLicenseText = "OAuthSwift is licensed under the MIT license:\nPermission is hereby granted, free of charge, to any person \nobtaining a copy of this software and associated documentation\n files (the “Software”), to deal in the Software without\n restriction, including without limitation the rights to use,\n copy, modify, merge, publish, distribute, sublicense, and/or\n sell copies of the Software, and to permit persons to whom\n the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies\n or substantial portions of the Software."
        
        let warrantyText = "THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
        
        let text = String(format: "%@%@%@%@%@", artistsText, otherArtwork, oAuthAck, mitLicenseText, warrantyText)

        acknowledgementsLabel.text = text
    }
    
    func setupScroll() {
        
        scrollView.delegate = self
        scrollView.scrollEnabled = true
        scrollView.directionalLockEnabled = true
    }
}

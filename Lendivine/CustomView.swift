//
//  CustomView.swift
//  Lendivine
//
//  Created by john bateman on 3/20/16.
//  Copyright © 2016 John Bateman. All rights reserved.
//

import UIKit
import MapKit

class CustomView: MKAnnotationView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var label: UILabel = UILabel()
//    var lendeeImage: UIImage = UIImage()
    
    //var myNames = ["dipen","laxu","anis","aakash","santosh","raaa","ggdds","house"]
    
//    override init(){
//        super.init()
//    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addCustomView()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomView() {
        label.frame = CGRectMake(0, -20, 100, 22)
        label.backgroundColor=UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.text = "label"
        label.hidden=false
        self.addSubview(label)
        
        let btn: UIButton = UIButton()
        btn.frame=CGRectMake(66, -18, 20, 20)
        btn.backgroundColor=UIColor.redColor()
        btn.setTitle("button", forState: UIControlState.Normal)
        btn.addTarget(self, action: "onChangeLabel", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(btn)
        
        let txtField : UITextField = UITextField()
        txtField.frame = CGRectMake(22, -18, 40, 20)
        txtField.backgroundColor = UIColor.grayColor()
        self.addSubview(txtField)
        txtField.text = "testing"
        
        let imageName = "pin-map-7.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: -20, width: 20, height: 20)
        self.addSubview(imageView)
    }
    
    func onChangeLabel() {
        self.label.text = "changelable selected"
    }
    
}
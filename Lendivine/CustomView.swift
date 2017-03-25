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

    var label: UILabel = UILabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
//    init() { //todo:swift3 - MKAnnotationView does not have an initializer with a frame:CGRect parameter
//    //init(frame: CGRect) { //todo:swift3 - MKAnnotationView does not have an initializer with a frame:CGRect parameter
//        //super.init(frame: frame)
//        super.init()
//        self.addCustomView()
//    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCustomView() {
        label.frame = CGRect(x: 0, y: -20, width: 100, height: 22)
        label.backgroundColor=UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.text = "label"
        label.isHidden=false
        self.addSubview(label)
        
        let btn: UIButton = UIButton()
        btn.frame=CGRect(x: 66, y: -18, width: 20, height: 20)
        btn.backgroundColor=UIColor.red
        btn.setTitle("button", for: UIControlState())
        btn.addTarget(self, action: #selector(CustomView.onChangeLabel), for: UIControlEvents.touchUpInside)
        self.addSubview(btn)
        
        let txtField : UITextField = UITextField()
        txtField.frame = CGRect(x: 22, y: -18, width: 40, height: 20)
        txtField.backgroundColor = UIColor.gray
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

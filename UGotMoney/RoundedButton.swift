//
//  RoundedButton.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/29/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import UIKit

//Custom button with rounded corners and custom colors
class RoundedButton: UIButton {

    var radius: CGFloat = 0.3
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        self.layer.cornerRadius = radius * self.frame.size.height
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.blueColor().CGColor
        self.layer.borderWidth = 1.5
        self.backgroundColor = UIColor.cyanColor()
        self.setTitleColor(UIColor.blueColor(), forState: .Disabled)
    }
    
 }

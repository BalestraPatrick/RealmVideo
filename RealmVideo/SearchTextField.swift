//
//  SearchTextField.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/10/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit

@IBDesignable class SearchTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 5.0
        tintColor = UIColor.whiteColor()
        
        let placeholder = NSAttributedString(string: "realm.io/...", attributes: [NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.5)])
        attributedPlaceholder = placeholder
        
        let clearButton = UIButton(type: .Custom)
        clearButton.setImage(UIImage(named: "clear-icon"), forState: .Normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 25.0, height: 15.0)
        clearButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        rightView = clearButton
        rightViewMode = .Always
        clearButton.addTarget(self, action: #selector(clearTextField), forControlEvents: .TouchUpInside)
    }
    
    func clearTextField() {
        text = ""
    }
    
    
}

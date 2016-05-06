//
//  WelcomeViewController.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/6/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var startVideo: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.layer.borderColor = UIColor.whiteColor().CGColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
        textField.delegate = self
        textField.tintColor = UIColor.whiteColor()
        
        let placeholder = NSAttributedString(string: "realm.io/...", attributes: [NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.5)])
        textField.attributedPlaceholder = placeholder
        
        setValidLink(false)
    }
    
    func setValidLink(value: Bool) {
        if value {
            startVideo.enabled = true
            startVideo.alpha = 1.0
        } else {
            startVideo.enabled = false
            startVideo.alpha = 0.5
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RealmVideo", let destination = segue.destinationViewController as? RealmVideoViewController {
            destination.videoURL = NSURL(string: textField.text!)!
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let types: NSTextCheckingType = .Link
        let detector = try? NSDataDetector(types: types.rawValue)
        let stringResults = detector?.firstMatchInString(textField.text!, options: [], range: NSMakeRange(0, textField.text!.characters.count))
        let pastedResults = detector?.firstMatchInString(string, options: [], range: NSMakeRange(0, string.characters.count))
        setValidLink(stringResults != nil || pastedResults != nil)
        return true
    }
}

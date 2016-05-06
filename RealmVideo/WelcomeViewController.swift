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
    @IBOutlet var pasteClipboardButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.layer.borderColor = UIColor.whiteColor().CGColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 5.0
        textField.delegate = self
        textField.tintColor = UIColor.whiteColor()
        textField.becomeFirstResponder()
        
        let placeholder = NSAttributedString(string: "realm.io/...", attributes: [NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.5)])
        textField.attributedPlaceholder = placeholder
        
        setValidLink("")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WelcomeViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WelcomeViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setValidLink(linkString: String) {
        let types: NSTextCheckingType = .Link
        let detector = try? NSDataDetector(types: types.rawValue)
        let stringResults = detector?.firstMatchInString(textField.text!, options: [], range: NSMakeRange(0, textField.text!.characters.count))
        let pastedResults = detector?.firstMatchInString(linkString, options: [], range: NSMakeRange(0, linkString.characters.count))
        
        if stringResults != nil || pastedResults != nil {
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
    
    // MARK: - IBAction
    
    @IBAction func pasteClipboardButtonPressed(sender: AnyObject) {
        if let pasteboardString = UIPasteboard.generalPasteboard().string {
            textField.text = pasteboardString
            setValidLink(pasteboardString)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        setValidLink(string)
        return true
    }
    
    // MARK: - UIKeyboard Notifications
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo,
            let keyboardSize = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.bottom = contentInset.bottom + keyboardSize.height
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        var contentInset = scrollView.contentInset
        contentInset.bottom = 0
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
}
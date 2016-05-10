//
//  WelcomeViewController.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/6/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, LinkUpdater {
    
    @IBOutlet weak var textField: SearchTextField!
    @IBOutlet weak var startVideoButton: UIButton!
    @IBOutlet weak var pasteClipboardButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.becomeFirstResponder()
        textField.linkUpdaterDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "RealmVideo", let destination = segue.destinationViewController as? RealmVideoViewController {
            destination.videoURL = NSURL(string: textField.text!)!
        } else if segue.identifier == "BrowseVideos", let destination = segue.destinationViewController as? BrowseVideosViewController {
            destination.welcome = self
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func pasteClipboardButtonPressed(sender: AnyObject) {
        if let pasteboardString = UIPasteboard.generalPasteboard().string {
            textField.text = pasteboardString
            updateLinkUI(pasteboardString.isValidLink())
        }
    }
    
    func updateLinkUI(isValid: Bool) {
        if isValid {
            startVideoButton.enabled = true
            startVideoButton.alpha = 1.0
        } else {
            startVideoButton.enabled = false
            startVideoButton.alpha = 0.5
        }
    }
    
    // MARK: - UIKeyboard Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        guard let keyboardInfo = notification.userInfo,
            let keyboardSize = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() else { return }
        
        var contentInset = scrollView.contentInset
        contentInset.bottom = contentInset.bottom + keyboardSize.height
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    func keyboardWillHide(notification: NSNotification) {
        var contentInset = scrollView.contentInset
        contentInset.bottom = 0
        
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
}
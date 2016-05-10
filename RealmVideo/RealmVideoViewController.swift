//
//  ViewController.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/5/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

let horizontalMargin: CGFloat = 20.0
let verticalMargin: CGFloat = 50.0

class RealmVideoViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet var floatingSlides: UIView!
    @IBOutlet weak var slideImageView: UIImageView!
    
    var positionOfSlides: CGFloat?
    var positionOfVideo: CGFloat?
    var slidesPosition = SlidePosition.BottomRight
    var token: dispatch_once_t = 0
    
    var videoURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = videoURL else { return }
        
        let request = NSURLRequest(URL: url)
        webView.delegate = self
        webView.scrollView.scrollEnabled = false
        webView.alpha = 0.0
        webView.loadRequest(request)
        
        updateSlidesPosition()
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(hideSlides))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        floatingSlides.addGestureRecognizer(singleTap)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(moveSlides))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        floatingSlides.addGestureRecognizer(doubleTap)
        
        singleTap.requireGestureRecognizerToFail(doubleTap)
        
        floatingSlides.layer.shadowOffset = CGSize(width: 1, height: 1)
        floatingSlides.layer.shadowColor = UIColor.blackColor().CGColor
        floatingSlides.layer.shadowOpacity = 0.5
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(playerDidStart), name: AVPlayerItemNewAccessLogEntryNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        // Start taking a screenshot of the slides each second to keep in sync with the video
        dispatch_once(&token) {
            NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(self.takeScreenshot), userInfo: nil, repeats: true)
        }
    }
    
    /// Called when the AVPlayer is started in the UIWebView
    func playerDidStart() {
        let window = UIApplication.sharedApplication().windows.last!
        window.rootViewController!.view.addSubview(floatingSlides)
        window.rootViewController?.view.bringSubviewToFront(floatingSlides)
        
    }
    
    /// Update slides position
    func updateSlidesPosition() {
        UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: [], animations: {
            self.floatingSlides.frame = self.position(self.slidesPosition, view: self.floatingSlides)
            }, completion: nil)
    }
    
    /// Move the slides to the next corner
    func moveSlides() {
        slidesPosition.next()
        updateSlidesPosition()
    }
    
    /// Hide the slides with a single tap
    func hideSlides() {
        var alpha: CGFloat = 1.0
        if floatingSlides.alpha == 1.0 {
            alpha = 0.1
        }
        UIView.animateWithDuration(1.0) {
            self.floatingSlides.alpha = alpha
        }
    }
    
    /// Take screenshot each second of the slides view and update the floating view
    func takeScreenshot() {
        // Focus on the video so that the user can start it
        if let position = positionOfVideo {
            webView.alpha = 1.0
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: position), animated: false)
        }
        
        // Take screenshot of the current slide and show it in the floating view
        if let _ = floatingSlides.superview, let position = positionOfSlides {
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: position), animated: false)
            UIGraphicsBeginImageContextWithOptions(self.view.frame.size, false, 0);
            self.view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext();
            slideImageView.image = image
            UIGraphicsEndImageContext()
        }
        
        // Hack to see if the MPMovieViewController is dimissed and we should focus again on the video
        if let position = positionOfVideo {
            webView.scrollView.setContentOffset(CGPoint(x: 0, y: position), animated: false)
        }
    }
    
    /// Returns the y coordinate of a given HTML #id element
    func positionOfElementWithId(elementID: String) -> CGFloat {
        let javascript = "function f(){ var r = document.getElementById('\(elementID)').getBoundingClientRect(); return '{{'+r.left+','+r.top+'},{'+r.width+','+r.height+'}}'; } f();"
        let result = webView.stringByEvaluatingJavaScriptFromString(javascript)!
        let rect = CGRectFromString(result)
        return rect.origin.y
    }
    
    /// Calculate the correct position for the slides
    func position(position: SlidePosition, view: UIView) -> CGRect {
        switch position {
        case .TopLeft:
            return CGRect(x: horizontalMargin, y: verticalMargin, width: view.frame.width, height: view.frame.height)
        case .TopRight:
            return CGRect(x: self.view.frame.width - horizontalMargin - view.frame.width, y: verticalMargin, width: view.frame.width, height: view.frame.height)
        case .BottomLeft:
            return CGRect(x: horizontalMargin, y: self.view.frame.height - verticalMargin - view.frame.height, width: view.frame.width, height: view.frame.height)
        case .BottomRight:
            return CGRect(x: self.view.frame.width - horizontalMargin - view.frame.width, y: self.view.frame.height - verticalMargin - view.frame.height, width: view.frame.width, height: view.frame.height)
        }
    }
    
    
    // MARK: - UIWebViewDelegate
    
    // Get position of the video and slides from the UIWebView
    func webViewDidFinishLoad(webView: UIWebView) {
        if positionOfSlides == nil {
            let position = positionOfElementWithId("slideshow-player") + 91.0
            if position > 91.0 {
                positionOfSlides = position
            }
        }
        
        if positionOfVideo == nil {
            let position = positionOfElementWithId("preroll-overlay") + 63
            if position > 63.0 {
                positionOfVideo = position
            } else if position == 63.0 {
                let youtubePosition = positionOfElementWithId("video-player") + 63
                positionOfVideo = youtubePosition
            }
        }
    }
    
    // Display error and dismiss current view controller
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        let alert = UIAlertController(title: error?.localizedDescription, message: nil, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        presentViewController(alert, animated: true, completion: nil)
    }
}


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

let horizontalMargin: CGFloat = 10.0
let verticalMargin: CGFloat = 50.0
let speakerDeckNavBarHeight = 27.0

class RealmVideoViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet var floatingSlides: UIView!
    
    var positionOfSlides: CGFloat?
    var positionOfVideo: CGFloat?
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
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(hideSlides))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        floatingSlides.addGestureRecognizer(singleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveSlides))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        floatingSlides.addGestureRecognizer(pan)
        singleTap.requireGestureRecognizerToFail(pan)
        
        floatingSlides.layer.shadowOffset = CGSize(width: 1, height: 1)
        floatingSlides.layer.shadowColor = UIColor.blackColor().CGColor
        floatingSlides.layer.shadowOpacity = 0.5
        
        let center = SlidePosition.BottomRight.snapTo(floatingSlides.frame)
        floatingSlides.center = center
        
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
        // Ensure we have a window, rootViewController, and that we're not adding a duplicate floating slide view
        guard let window = UIApplication.sharedApplication().windows.last,
            let rootViewController = window.rootViewController where
            rootViewController.view.subviews.contains(floatingSlides) == false else { return }
        
        rootViewController.view.addSubview(floatingSlides)
        rootViewController.view.bringSubviewToFront(floatingSlides)
    }
    
    /// Move the slides to the next corner
    func moveSlides(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .Changed:
            if let view = pan.view {
                let translation = pan.translationInView(view)
                view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
                pan.setTranslation(CGPointZero, inView: view)
            }
        case .Ended:
            if let panView = pan.view {
                UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 2.0, options: [], animations: {
                    self.snapPositionToNearestPoint(panView.center, view: panView)
                    }, completion: nil)
            }
        default: break
        }
    }
    
    /// Snap the slides to the nearest corner.
    ///
    /// - parameter point: Point where the view was released.
    /// - parameter view:  Floating view displaying the slides.
    func snapPositionToNearestPoint(point: CGPoint, view: UIView) {
        let sector = SlidePosition.findPosition(point, slidesSize: view.frame)
        let snappedCenter = sector.snapTo(view.frame)
        view.center = snappedCenter
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
    
    // MARK: - UIWebViewDelegate
    
    // Get position of the video and slides from the UIWebView
    func webViewDidFinishLoad(webView: UIWebView) {
        if positionOfSlides == nil && !webView.loading {
            let position = positionOfElementWithId("slideshow-player") + CGFloat(speakerDeckNavBarHeight)
            positionOfSlides = position
        }
        
        if positionOfVideo == nil && !webView.loading {
            let position = positionOfElementWithId("preroll-overlay")
            if position == 0.0 {
                let youtubePosition = positionOfElementWithId("video-player")
                positionOfVideo = youtubePosition
            } else {
                positionOfVideo = position
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

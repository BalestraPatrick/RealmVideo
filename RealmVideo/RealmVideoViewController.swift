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

class RealmVideoViewController: UIViewController, UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var floatingSlides: FloatingSlides!
    
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
    
    // MARK: - UIWebViewDelegate
    
    // Get position of the video and slides from the UIWebView
    func webViewDidFinishLoad(webView: UIWebView) {
        if positionOfSlides == nil && !webView.loading {
            let position = webView.yPositionOfElementWithID(PageElements.slideshowPlayer) + speakerDeckNavBarHeight
            positionOfSlides = position
        }
        
        if positionOfVideo == nil && !webView.loading {
            let position = webView.yPositionOfElementWithID(PageElements.preRollOverlay)
            if position == 0.0 {
                let youtubePosition = webView.yPositionOfElementWithID(PageElements.videoPlayer)
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

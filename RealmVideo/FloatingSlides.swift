//
//  FloatingSlides.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/12/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit

class FloatingSlides: UIView {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.5
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(hideSlides))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        addGestureRecognizer(singleTap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveSlides))
        pan.maximumNumberOfTouches = 1
        pan.minimumNumberOfTouches = 1
        addGestureRecognizer(pan)
        singleTap.requireGestureRecognizerToFail(pan)
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
    
    // MARK: UIPanGestureRecognizer
    
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
    
    // MARK: UITapGestureRecognizer
    
    /// Hide the slides with a single tap
    func hideSlides() {
        var alpha: CGFloat = 1.0
        if alpha == 1.0 {
            alpha = 0.1
        }
        UIView.animateWithDuration(1.0) {
            self.alpha = alpha
        }
    }
}

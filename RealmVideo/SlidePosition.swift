//
//  SlidePosition.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/10/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit

private let halfWidth = UIScreen.mainScreen().bounds.width / 2
private let halfHeight = UIScreen.mainScreen().bounds.height / 2

enum SlidePosition {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
}

extension SlidePosition {
    
    /// Returns the center point for the slides view.
    ///
    /// - returns: The point of the slides.
    func snapTo(slidesSize: CGRect) -> CGPoint {
        
        var nearestPoint = CGPoint()
        
        switch self {
        case .TopLeft:
            nearestPoint.x = slidesSize.size.width / 2 + horizontalVideoMargin
            nearestPoint.y = slidesSize.size.height / 2 + verticalVideoMargin
        case .TopRight:
            nearestPoint.x = (halfWidth * 2) - slidesSize.size.width / 2 - horizontalVideoMargin
            nearestPoint.y = slidesSize.size.height / 2 + verticalVideoMargin
        case .BottomLeft:
            nearestPoint.x = slidesSize.size.width / 2 + horizontalVideoMargin
            nearestPoint.y = (halfHeight * 2) - (slidesSize.size.height / 2) - verticalVideoMargin
        case .BottomRight:
            nearestPoint.x = (halfWidth * 2) - slidesSize.size.width / 2 - horizontalVideoMargin
            nearestPoint.y = (halfHeight * 2) - (slidesSize.size.height / 2) - verticalVideoMargin
        }
        return nearestPoint
    }
    
    static func findPosition(point: CGPoint, slidesSize: CGRect) -> SlidePosition {
        if point.x <= halfWidth && point.y <= halfHeight {
            return .TopLeft
        } else if point.x <= halfWidth && point.y > halfHeight {
            return .BottomLeft
        } else if point.x > halfWidth && point.y <= halfHeight {
            return .TopRight
        } else {
            return .BottomRight
        }
    }
}

extension UIWebView {
    
    /// Returns the y coordinate of a given HTML #id element
    func yPositionOfElementWithID(elementID: String) -> CGFloat {
        let javascript = "function f(){ var r = document.getElementById('\(elementID)').getBoundingClientRect(); return '{{'+r.left+','+r.top+'},{'+r.width+','+r.height+'}}'; } f();"
        let result = stringByEvaluatingJavaScriptFromString(javascript)!
        let rect = CGRectFromString(result)
        return rect.origin.y
    }
}

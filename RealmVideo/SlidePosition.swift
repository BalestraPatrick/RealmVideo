//
//  SlidePosition.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/10/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import UIKit

enum SlidePosition {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
}

let halfWidth = UIScreen.mainScreen().bounds.width / 2
let halfHeight = UIScreen.mainScreen().bounds.height / 2

extension SlidePosition {
    
    /// Returns the center point for the slides view.
    ///
    /// - returns: The point of the slides.
    func snapTo(slidesSize: CGRect) -> CGPoint {
        
        var nearestPoint = CGPoint()
        
        switch self {
        case .TopLeft:
            nearestPoint.x = slidesSize.size.width / 2 + horizontalMargin
            nearestPoint.y = slidesSize.size.height / 2 + verticalMargin
        case .TopRight:
            nearestPoint.x = (halfWidth * 2) - slidesSize.size.width / 2 - horizontalMargin
            nearestPoint.y = slidesSize.size.height / 2 + verticalMargin
        case .BottomLeft:
            nearestPoint.x = slidesSize.size.width / 2 + horizontalMargin
            nearestPoint.y = (halfHeight * 2) - (slidesSize.size.height / 2) - verticalMargin
        case .BottomRight:
            nearestPoint.x = (halfWidth * 2) - slidesSize.size.width / 2 - horizontalMargin
            nearestPoint.y = (halfHeight * 2) - (slidesSize.size.height / 2) - verticalMargin
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
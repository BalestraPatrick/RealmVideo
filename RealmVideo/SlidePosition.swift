//
//  SlidePosition.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/10/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import Foundation

enum SlidePosition {
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    
    mutating func next() {
        switch self {
        case .TopLeft:
            self = .TopRight
        case .TopRight:
            self = .BottomLeft
        case .BottomLeft:
            self = .BottomRight
        case .BottomRight:
            self = .TopLeft
        }
    }
}
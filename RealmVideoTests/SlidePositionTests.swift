//
//  SlidePositionTests.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/12/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import XCTest
@testable import RealmVideo

class SlidePositionTests: XCTestCase {
    
    let rect = CGRect(x: 0, y: 0, width: 1136, height: 768)
    
    func test_slidePositionTopLeft() {
        let position = SlidePosition.findPosition(CGPointZero, slidesSize: rect)
        XCTAssertEqual(position, SlidePosition.TopLeft)
    }
    
    func test_slidePositionTopRight() {
        let position = SlidePosition.findPosition(CGPoint(x: 1000, y: 0), slidesSize: rect)
        XCTAssertEqual(position, SlidePosition.TopRight)
    }
    
    func test_slidePositionBottomLeft() {
        let position = SlidePosition.findPosition(CGPoint(x: 0, y: 700), slidesSize: rect)
        XCTAssertEqual(position, SlidePosition.BottomLeft)
    }
    
    func test_slidePositionBottomRight() {
        let position = SlidePosition.findPosition(CGPoint(x: 1000, y: 700), slidesSize: rect)
        XCTAssertEqual(position, SlidePosition.BottomRight)
    }
}

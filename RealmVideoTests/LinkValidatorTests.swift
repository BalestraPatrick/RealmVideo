//
//  RealmVideoTests.swift
//  RealmVideoTests
//
//  Created by Patrick Balestra on 5/12/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import XCTest
@testable import RealmVideo

class LinkValidatorTests: XCTestCase {
    
    func test_isLinkValid() {
        let link1 = "https://realm.io/"
        let link2 = "https://realm.io/news"
        XCTAssertTrue(link1.isValidLink())
        XCTAssertTrue(link2.isValidLink())
    }
    
    func test_isLinkInvalid() {
        let link1 = "https:/realm"
        let link2 = "www.realm"
        XCTAssertFalse(link1.isValidLink())
        XCTAssertFalse(link2.isValidLink())
    }
}
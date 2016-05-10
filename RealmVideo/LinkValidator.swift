//
//  LinkValidator.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/10/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import Foundation

extension String {
    
    func isValidLink() -> Bool {
        let types: NSTextCheckingType = .Link
        let detector = try? NSDataDetector(types: types.rawValue)
        let stringResults = detector?.firstMatchInString(self, options: [], range: NSMakeRange(0, characters.count))
        let pastedResults = detector?.firstMatchInString(self, options: [], range: NSMakeRange(0, characters.count))
        if stringResults != nil || pastedResults != nil {
            return true
        }
        return false
    }
}
//
//  RealmParser.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/6/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import Foundation
import Ji

enum ParserError: ErrorType {
    case Offline
}

class RealmParser {
    
    var videos = [Video]()
    
    init() throws {
        let url = NSURL(string: "https://realm.io/news/")!
        let document = Ji(htmlURL: url)
        let possiblePosts = document?.xPath("//div[contains(concat(' ', @class, ' '), ' post ')]")
        guard let posts = possiblePosts else { throw ParserError.Offline }
        
        for post in posts {
            if let attributes = post.attributes["data-tags"] where attributes.containsString("video") {
                for child in post.children {
                    let a = child.firstChildWithName("a")!
                    let content = a.content!
                    let link = a.attributes["href"]!
                    if content != "Read More…" {
                        videos.append(Video(title: content, url: "https://realm.io\(link)"))
                    }
                }
            }
        }
    }
}
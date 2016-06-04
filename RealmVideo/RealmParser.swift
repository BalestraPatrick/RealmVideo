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
        let possiblePosts = document?.xPath("//div[contains(concat(' ', @class, ' '), ' article ')]")
        guard let posts = possiblePosts else { throw ParserError.Offline }
        
        for post in posts {
            if let attributes = post.attributes["data-tags"] where attributes.containsString("video") {
                for child in post.children {
                    let link = child.attributes["href"]
                    let content = child.firstDescendantWithAttributeName("class", attributeValue: "news-headline hidden-xs")?.content
                    _ = attributes // TODO: show tags in UI for better discovery
                    if let content = content where content != "Read More…", let link = link {
                        videos.append(Video(title: content, url: "https://realm.io\(link)"))
                    }
                }
            }
        }
    }
}
//
//  RealmParser.swift
//  RealmVideo
//
//  Created by Patrick Balestra on 5/6/16.
//  Copyright © 2016 Patrick Balestra. All rights reserved.
//

import Foundation
import Ji

class RealmParser {
    
    var videos = [Video]()
    
    init() {
        let url = NSURL(string: "https://realm.io/news/")!
        let document = Ji(htmlURL: url)
        let posts = document?.xPath("//div[contains(concat(' ', @class, ' '), ' post ')]")
        
        for post in posts! {
            if let attributes = post.attributes["data-tags"] where attributes.containsString("video") {
                for child in post.children {
                    let a = child.firstChildWithName("a")!
                    let content = a.content!
                    let link = a.attributes["href"]!
                    if content != "Read More…" {
                        videos.append(Video(title: content, url: "https://www.realm.io\(link)"))
                    }
                }
            }
        }
    }
}
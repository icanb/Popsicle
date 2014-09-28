//
//  PageCache.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import Foundation

class PageCache : Storable, NSCoding {
    
    var full_url: String = ""
    var url_path: String = ""
    var html: String = ""
    var title: String = ""

    var parameters: [String] = []
    var last_update:NSDate = NSDate.date()

    override init() {
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        self.init()
        
        self.full_url = aDecoder.decodeObjectForKey("full_url") as String!
        self.url_path = aDecoder.decodeObjectForKey("url_path") as String!
        self.html = aDecoder.decodeObjectForKey("html") as String!
        self.title = aDecoder.decodeObjectForKey("title") as String!
        self.parameters = aDecoder.decodeObjectForKey("parameters") as [String]
        self.last_update = aDecoder.decodeObjectForKey("last_update") as NSDate!
    }

    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.full_url, forKey:"full_url")
        aCoder.encodeObject(self.url_path, forKey:"url_path")
        aCoder.encodeObject(self.html, forKey:"html")
        aCoder.encodeObject(self.title, forKey:"title")
        aCoder.encodeObject(self.parameters, forKey:"parameters")
        aCoder.encodeObject(self.last_update, forKey:"last_update")

    }
}


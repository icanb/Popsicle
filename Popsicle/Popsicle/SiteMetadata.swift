//
//  SiteMetadata.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import Foundation
import UIKit

class SiteMetadata : Storable, NSCoding {
    
    var hostname:String = ""
    var root_url = ""
    var port:String = "80"
    var last_update: NSDate = NSDate()
    var directory_path:String = "/"
    var favicon:String = ""
    var pages: [PageCache] = []
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    override init() {
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        self.init()
        
        self.hostname = aDecoder.decodeObjectForKey("hostname") as String!
//        self.root_url = aDecoder.decodeObjectForKey("root_url") as String!
        self.port = aDecoder.decodeObjectForKey("port") as String!
        self.last_update = aDecoder.decodeObjectForKey("last_update") as NSDate
        self.directory_path = aDecoder.decodeObjectForKey("directory_path") as String!
        self.pages = aDecoder.decodeObjectForKey("pages") as [PageCache]

    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.hostname, forKey:"hostname")
        aCoder.encodeObject(self.port, forKey:"port")
        aCoder.encodeObject(self.last_update, forKey:"last_update")
        aCoder.encodeObject(self.directory_path, forKey:"directory_path")
        aCoder.encodeObject(self.pages, forKey:"pages")
    }

    
    func getPage(hyperlink:String) -> PageCache? {
        for page in self.pages {
            if (page.url_path == hyperlink) {
                return page
            }
        }
        
        return nil
    }

    func getPageFromFullURL(url:String) -> PageCache? {
        for page in self.pages {
            if (page.full_url == url) {
                return page
            }
        }
        
        return nil
    }
    
}

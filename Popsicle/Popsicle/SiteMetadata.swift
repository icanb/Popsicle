//
//  SiteMetadata.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import Foundation

class SiteMetadata : Storable, NSCoding {
    
    var hostname:String = ""
    var port:String = "80"
    var last_update: NSDate = NSDate.date()
    var directory_path:String = "/"
    var favicon:String = ""
    var pages: [PageCache] = []

    override init() {
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        self.init()
        
        self.hostname = aDecoder.decodeObjectForKey("hostname") as String!
        self.port = aDecoder.decodeObjectForKey("port") as String!
        self.last_update = aDecoder.decodeObjectForKey("last_update") as NSDate
        self.directory_path = aDecoder.decodeObjectForKey("directory_path") as String!
        println(aDecoder.decodeObjectForKey("pages"))
        self.pages = aDecoder.decodeObjectForKey("pages") as [PageCache]
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.hostname, forKey:"hostname")
        aCoder.encodeObject(self.port, forKey:"port")
        aCoder.encodeObject(self.last_update, forKey:"last_update")
        aCoder.encodeObject(self.directory_path, forKey:"directory_path")
        aCoder.encodeObject(self.pages, forKey:"pages")
    }
    
}


//
//  Device.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import Foundation

class Device : Storable, NSCoding {
    
    var uid: String = ""
    var name: String = ""
    var cache: [SiteMetadata] = []

    override init() {
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        self.init()
        
        self.uid = aDecoder.decodeObjectForKey("uid") as String!
        self.name = aDecoder.decodeObjectForKey("name") as String!
        self.cache = aDecoder.decodeObjectForKey("cache") as [SiteMetadata]
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.uid, forKey:"uid")
        aCoder.encodeObject(self.name, forKey:"name")
        aCoder.encodeObject(self.cache, forKey:"cache")
    }

    func save() {
        
    }
}

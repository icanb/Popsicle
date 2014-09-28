
//
//  StorageManager.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/27/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import Foundation

class StorageManager {
    
    
    var device:Device?

    init(device currentDevice:Device?) {
        
//        if (self.device != nil) {
            self.device = currentDevice
//        }

    }

    func saveSite(host hostName:String?, port portNmr:String? = "80") -> Bool {
    
        for site in self.device!.cache {
            if (site.hostname == hostName) {
                return false;
            }
        }

        
        var cleanHostname = hostName!.stringByReplacingOccurrencesOfString(".", withString: "_", options: NSStringCompareOptions.LiteralSearch, range: nil)
        var fileName = "/site_"+cleanHostname+".sickle"

        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var storePath = documentsPath.stringByAppendingPathComponent(fileName)
        var checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(storePath)) {
            print("WARNING: this should not happen")
        }
        
        // Create and save the site
        var newSite = SiteMetadata()
        newSite.hostname = hostName!
        newSite.port = "80"
        newSite.storePath = storePath
        newSite.updateStorage()
        
        // Add the site to the cache and update
        self.device!.cache.append(newSite)
        self.device!.updateStorage()

        return true;
    }
    
    func savePage() {
        
    }
    
    func getSites() {
        
    }
}
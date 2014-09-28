
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
    
    func cacheHtmlPages(stringUrl: String) -> Void {
        let url = NSURL(string: stringUrl)
        
        // TODO: recursively get shit from links.
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            //            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            let response = NSString(data: data, encoding: NSUTF8StringEncoding)
            var hyperlinks = self.getHyperlinksFromHtml(response)
            // println(hyperlinks)
        }
        
        task.resume()
        
    }
    
    func getHyperlinksFromHtml(htmlString: String) -> Array<String> {
        
        var err : NSError?
        var parser = HTMLParser(html: htmlString, error: &err)
        if err != nil {
            println(err)
            exit(1)
        }
        
        var bodyNode = parser.body
        
        var hyperlinkList: [String] = []
        
        if let inputNodes = bodyNode?.findChildTags("a") {
            for node in inputNodes {
                hyperlinkList.append(node.getAttributeNamed("href"))
            }
        }
        
        return hyperlinkList
    }
}
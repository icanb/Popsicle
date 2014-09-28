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
    var port:String = "80"
    var last_update: NSDate = NSDate.date()
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
    
    func crawl() -> Bool {
        println(self.hostname)
        if (self.hostname == "") {
            println ("no host name")
            return false
        }
        
        var count:Int = 5
        var depth:Int = 2
        let stringUrl = self.sanitizeUrl(hostname, hostname: hostname, currentPath: nil)
        self.recursiveCrawl(stringUrl, primaryKey:stringUrl, countRemaining: count, depthRemaining: depth)
        
        return true
        
    }
    
    func recursiveCrawl(stringUrl: String, primaryKey originalHyperlink:String, countRemaining count:Int, depthRemaining depth:Int) -> Void {
        if (depth == 0) {
            println(self.pages)
            return
        }
        
        let url = NSURL(string: stringUrl)
        println(url)
        var dynamicCount:Int = count
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
//                        println(NSString(data: data, encoding: NSUTF8StringEncoding))
            let response = NSString(data: data, encoding: NSUTF8StringEncoding) as String
            var hyperlinks = self.getHyperlinksFromHtml(response)
            var sm:StorageManager = self.appDelegate.getStorageManager()
            sm.savePageYo(host: self.hostname, port: "80", full_url: stringUrl, parameters: [], title: "temp", html: response)
            for hyperlink in hyperlinks {
                if (dynamicCount < 0) {
                    break
                }
                if (self.getPage(hyperlink) == nil) {
                    dynamicCount--
                    let sanitizedHyperlink = self.sanitizeUrl(hyperlink, hostname: self.hostname, currentPath: stringUrl)
                    self.recursiveCrawl(sanitizedHyperlink, primaryKey:hyperlink, countRemaining: count, depthRemaining: depth-1)
                }

            }
        }
        
        task.resume()
        
    }
    
    func getPage(hyperlink:String) -> PageCache? {
        for page in self.pages {
            if (page.url_path == hyperlink) {
                return page
            }
        }
        
        return nil
    }
    
    func sanitizeUrl(urlString: String, hostname hostnameStr:String, currentPath currentPathStr:String?) -> String {
        // case 1: http://cnn.com (protocol + domain)
        // case 2: cnn.com (no protocol + yes domain)
        // case 3: /abs-path-from-domain
        // case 4: relative-path-from-location
        // case 5: #anchor - ignore
        
        if (urlString == "") {
            return urlString
        }
        
        let hasProtocol:Bool = urlString.rangeOfString("http://") != nil
        
        var sanitizedUrl:String
        if (hasProtocol) {
            sanitizedUrl = urlString
        } else {
            if (urlString == hostnameStr) {
                sanitizedUrl = "http://" + hostnameStr
            } else {
                let firstChar:String = String(Array(urlString)[0])
                if (firstChar == "#") {
                    sanitizedUrl = ""
                } else if (firstChar == "/") {
                    sanitizedUrl = "http://" + hostname + urlString
                } else {
                    sanitizedUrl = currentPathStr! + "/" + urlString
                }
            }
        }
        
        return sanitizedUrl
    }
    
    func getHyperlinksFromHtml(htmlString: String) -> Array<String> {
        
        var err : NSError?
        var parser = HTMLParser(html: htmlString, error: &err)
//        if err != nil {
//            println(err)
//            exit(1)
//        }
        
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

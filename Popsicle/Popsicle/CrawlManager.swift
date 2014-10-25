//
//  CrawlManager.swift
//  Popsicle
//
//  Created by Ilter Canberk on 10/25/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import Foundation
import UIKit

class CrawlManager:NSObject {

    class func getAppDelegate() -> AppDelegate {
        return  UIApplication.sharedApplication().delegate as AppDelegate
    }

    class func crawl(site:SiteMetadata) -> Bool {
        
        if (site.hostname == "") {
            println ("no host name")
            return false
        }
        
        var count:Int = 20
        var depth:Int = 2
    
        let stringUrl = self.sanitizeUrl(site.hostname + site.root_url,
            hostname: site.hostname + site.root_url,
            currentPath: site.hostname)

        self.recursiveCrawl(site, url:stringUrl, primaryKey:stringUrl, countRemaining: count, depthRemaining: depth)
        
        
        //        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string:"http://g.etfv.co/"+stringUrl)) {(data, response, error) in
        //            //            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        //            var response = NSString(data: data, encoding: NSUTF8StringEncoding) as String
        //            println(response)
        //            self.favicon = response
        //            self.updateStorage()
        //
        //            //page.html = page.html + "<style type='text/css'>" + response + "</style>"
        //            //page.updateStorage()
        //            //                        println("RESPONSE:\(response)")
        //        }
        //        
        //        task.resume()
        
        return true
        
    }
    
    class func sanitizeUrl(urlString: String, hostname hostnameStr:String, currentPath currentPathStr:String?) -> String {
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
                    sanitizedUrl = "http://" + hostnameStr + urlString
                } else {
                    sanitizedUrl = currentPathStr! + "/" + urlString
                }
            }
        }
        println(sanitizedUrl)
        return sanitizedUrl
    }

    
    class func recursiveCrawl(site:SiteMetadata, url stringUrl: String, primaryKey originalHyperlink:String, countRemaining count:Int, depthRemaining depth:Int) -> Void {
        

        if (depth == 0) {
            return
        }
        
        let url = NSURL(string: stringUrl)
        var dynamicCount:Int = count
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            
            let response = NSString(data: data, encoding: NSUTF8StringEncoding) as String
            var (hyperlinks, title, cssLinks) = self.parseHtml(response)
            
            var sm:StorageManager = self.getAppDelegate().getStorageManager()

            var page = sm.savePage(host: site.hostname, port: "80", full_url: stringUrl, url_path: originalHyperlink, parameters: [], title: title, html: response)
            // append CSS stuff in
            for cssLink in cssLinks {
                self.injectCSS(site, page: page, cssUrl: cssLink, stringUrl: stringUrl)
            }
            for hyperlink in hyperlinks {
                if (dynamicCount < 0) {
                    break
                }
                if (site.getPage(hyperlink) == nil) {
                    dynamicCount--
                    let sanitizedHyperlink = self.sanitizeUrl(hyperlink, hostname: site.hostname, currentPath: stringUrl)
                    if (sanitizedHyperlink != "") {
                        self.recursiveCrawl(site, url:sanitizedHyperlink, primaryKey:hyperlink, countRemaining: count, depthRemaining: depth-1)
                    }
                    
                }
                
            }
        }
        
        task.resume()
        
    }
 
    class func parseHtml(htmlString: String) -> (Array<String>, String, Array<String>) {
        
        var err : NSError?
        var parser = HTMLParser(html: htmlString, error: &err)
        //        if err != nil {
        //            println(err)
        //            exit(1)
        //        }
        
        var bodyNode = parser.body
        var headNode = parser.head
        
        var hyperlinkList: [String] = []
        
        if let inputNodes = bodyNode?.findChildTags("a") {
            for node in inputNodes {
                hyperlinkList.append(node.getAttributeNamed("href"))
            }
        }
        
        var titleNode:String = ""
        if let titleNodes = headNode?.findChildTags("title") {
            titleNode = titleNodes[0].contents
        }
        
        var cssLinkList: [String] = []
        if let inputNodes = headNode?.findChildTags("link") {
            for node in inputNodes {
                var cssUrl = node.getAttributeNamed("href")
                
                if cssUrl.rangeOfString(".css") != nil {
                    //                    cssUrl = sanitizeUrl(cssUrl, hostname: url.host!, currentPath: url.absoluteString)
                    cssLinkList.append(cssUrl)
                    println("cssUrl: \(cssUrl)")
                    
                    //                    let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string:cssUrl)) {(data, response, error) in
                    //                        //            println(NSString(data: data, encoding: NSUTF8StringEncoding))
                    //                        let response = NSString(data: data, encoding: NSUTF8StringEncoding)
                    //                        //                        println("RESPONSE:\(response)")
                    //                    }
                    //
                    //                    task.resume()
                }
            }
        }
        
        return (hyperlinkList, titleNode, cssLinkList)
    }
    
    class func injectCSS(site: SiteMetadata, page: PageCache, cssUrl: String, stringUrl: String) -> Void {
        //        var err : NSError?
        //        var parser = HTMLParser(html: html, error: &err)
        //        if err != nil {
        //            exit(1)
        //        }
        let sanitizedHyperlink = self.sanitizeUrl(cssUrl, hostname: site.hostname, currentPath: stringUrl)
        let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string:sanitizedHyperlink)!) {(data, response, error) in
            //            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            var response = NSString(data: data, encoding: NSUTF8StringEncoding) as String
            
            page.html = page.html + "<style type='text/css'>" + response + "</style>"
            page.updateStorage()
            //                        println("RESPONSE:\(response)")
        }
        
        task.resume()
        
        //        var headNode = parser.head
        //
        //        var hyperlinkList: [String] = []
        
        //        if let inputNodes = headNode?.findChildTags("link") {
        //            for node in inputNodes {
        //                var CSS_URL = node.getAttributeNamed("href")
        //
        //                if CSS_URL.rangeOfString(".css") != nil {
        //                    CSS_URL = sanitizeUrl(CSS_URL, hostname: url.host!, currentPath: url.absoluteString)
        //                    println("CSSURL:\(CSS_URL)")
        //
        //                    let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string:CSS_URL)) {(data, response, error) in
        //                        //            println(NSString(data: data, encoding: NSUTF8StringEncoding))
        //                        let response = NSString(data: data, encoding: NSUTF8StringEncoding)
        ////                        println("RESPONSE:\(response)")
        //                    }
        //                    
        //                    task.resume()
        //                }
        //            }
        //        }
    }
}
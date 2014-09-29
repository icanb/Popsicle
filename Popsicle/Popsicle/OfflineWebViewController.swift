//
//  OfflineWebViewController.swift
//  Popsicle
//
//  Created by Mirai Akagawa on 9/28/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

class OfflineWebViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    var appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
    
    var initialPage:PageCache?
    var rooSite:SiteMetadata?
        
    override func viewDidLoad() {
        super.viewDidLoad()

        let html = self.initialPage?.html
        var urlStr = self.initialPage?.full_url
        self.title = self.initialPage?.title
        var url:NSURL
        if (urlStr != nil) {
            url = NSURL(string: urlStr!)
        } else {
            println("SHIT WENT DOWN")
            exit(1)
        }
        webView.loadHTMLString(html, baseURL: url)
        webView.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webView(webView: UIWebView!, didFailLoadWithError error: NSError!) {
        println("Webview fail with error \(error)");
    }
    
    func webView(webView: UIWebView!, shouldStartLoadWithRequest request: NSURLRequest!, navigationType: UIWebViewNavigationType) -> Bool {
        
        if (navigationType == UIWebViewNavigationType.LinkClicked) {
            webView.stopLoading()
            var page = self.rooSite?.getPageFromFullURL(request.URL.absoluteString!)
            if (page != nil) {
                println("CACHE HIT!!!")
                let html = page?.html
                webView.loadHTMLString(html, baseURL: request.URL)
                
            } else {
                var alert = UIAlertView(title: "Uh oh!", message: "Seems like this page is not cached, sorry!", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            return true
        } else {
            return true
        }
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        println("Webview started Loading")
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        println("Webview did finish load")
    }

}

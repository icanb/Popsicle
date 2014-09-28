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
    
    let tempHtmlString1:String =
    "<!DOCTYPE html>" +
        "<html>" +
        "<head>" +
        "<title>Home Page</title>" +
        "</head>" +
        "<body>" +
        "<h1>Home Page</h1>" +
        "<p><a href='index.html'>home</a></p>" +
        "<p><a href='html/about.html'>about</a></p>" +
        "<p><a href='html/services.html'>services</a></p>" +
        "<p><a href='html/contact.html'>contact</a></p>" +
        "</body>" +
    "</html>"

    let tempHtmlString2:String =
    "<!DOCTYPE html>" +
        "<html>" +
        "<head>" +
        "<title>Home Page</title>" +
        "</head>" +
        "<body>" +
        "<h1>HIJACK SUCCESS</h1>" +
        "<p><a href='index.html'>home</a></p>" +
        "<p><a href='html/about.html'>about</a></p>" +
        "<p><a href='html/services.html'>services</a></p>" +
        "<p><a href='html/contact.html'>contact</a></p>" +
        "</body>" +
    "</html>"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL(string: "http://www.google.com")
        webView.loadHTMLString(tempHtmlString1, baseURL: url)
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
        println("--> STARTING LOAD")
        let url = NSURL(string: "http://www.google.com")
        println(request.URL)
        
        
        if (navigationType == UIWebViewNavigationType.LinkClicked) {
            println("here")
            webView.stopLoading()
            webView.loadHTMLString(tempHtmlString2, baseURL: url)
            return true
        }
        
        
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        println("Webview started Loading")
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        println("Webview did finish load")
    }

}

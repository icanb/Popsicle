//
//  OfflineWebViewController.swift
//  Popsicle
//
//  Created by Mirai Akagawa on 9/28/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

class OfflineWebViewController: UIViewController, UIWebViewDelegate, UIViewControllerTransitioningDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var downButton: UIBarButtonItem!

    var appDelegate = UIApplication.sharedApplication().delegate! as AppDelegate
    
    var initialPage:PageCache?
    var rooSite:SiteMetadata?
    var history:[PageCache] = []
    
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
        
        addToHistory(self.initialPage!)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.commonInit()
    }
    
    func commonInit() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
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
                addToHistory(page!)
                
            } else {
                var alert = UIAlertView(title: "Uh oh!", message: "Seems like this page is not cached, sorry!", delegate: self, cancelButtonTitle: "OK")
                alert.show()
            }
            return true
        } else {
            return true
        }
    }
    
    func addToHistory(page:PageCache) {
        history.append(page)
    }
    
    func webViewDidStartLoad(webView: UIWebView!) {
        println("Webview started Loading")
    }
    
    func webViewDidFinishLoad(webView: UIWebView!) {
        println("Webview did finish load")
    }

    @IBAction func goBack(sender: AnyObject) {
        webView.goBack()
    }
    
    @IBAction func goDown(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }

    // ---- UIViewControllerTransitioningDelegate methods
    
    func presentationControllerForPresentedViewController(presented: UIViewController!, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController!) -> UIPresentationController! {
        
        if presented == self {
            return CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
        }
        
        return nil
    }
    
    func animationControllerForPresentedController(presented: UIViewController!, presentingController presenting: UIViewController!, sourceController source: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        
        if presented == self {
            return CustomPresentationAnimationController(isPresenting: true)
        }
        else {
            return nil
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController!) -> UIViewControllerAnimatedTransitioning! {
        
        if dismissed == self {
            return CustomPresentationAnimationController(isPresenting: false)
        }
        else {
            return nil
        }
    }
    
}

//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    @IBOutlet var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        println("cheeeel")
        let url = NSURL(string: "http://google.com")
        let request = NSURLRequest(URL: url)
//        webView.loadRequest(request)
        webView.loadHTMLString("hello world", baseURL: url)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


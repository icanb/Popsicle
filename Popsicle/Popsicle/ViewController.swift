//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit
import Foundation
import HTMLParsingFramework

class ViewController: UIViewController {

    let tempHtmlString:String =
    "<!DOCTYPE html>" +
    "<html>" +
        "<head>" +
            "<title>Home Page</title>" +
        "</head>" +
        "<body>" +
            "<img src='images/logo.png'>" +
            "<h1>Home Page</h1>" +
            "<p><a href='index.html'>home</a></p>" +
            "<p><a href='html/about.html'>about</a></p>" +
            "<p><a href='html/services.html'>services</a></p>" +
            "<p><a href='html/contact.html'>contact</a></p>" +
        "</body>" +
    "</html>"

    @IBOutlet var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var lol = TFHpple
        
        let html = "<html><head></head><body><ul><li><input type='image' name='input1' value='string1value' class='abc' /></li><li><input type='image' name='input2' value='string2value' class='def' /></li></ul><span class='spantext'><b>Hello World 1</b></span><span class='spantext'><b>Hello World 2</b></span><a href='example.com'>example(English)</a><a href='example.co.jp'>example(JP)</a></body>"
        
        var err : NSError?
        
        var parser     = TFHpple(html: html, error: &err)
        if err != nil {
            println(err)
            exit(1)
        }
        
        var bodyNode   = parser.body
        
        if let inputNodes = bodyNode?.findChildTags("b") {
            for node in inputNodes {
                println(node.contents)
            }
        }
        
        if let inputNodes = bodyNode?.findChildTags("a") {
            for node in inputNodes {
                println(node.contents)
                println(node.getAttributeNamed("href"))
            }
        }

        
        println("cheeeel")
        let url = NSURL(string: "http://google.com")
        let request = NSURLRequest(URL: url)
//        webView.loadRequest(request)
        webView.loadHTMLString("hello world", baseURL: url)
        // Do any additional setup after loading the view, typically from a nib.
        var shit = getHyperlinksFromHtml(tempHtmlString)
        println(shit)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getHyperlinksFromHtml(htmlString: String) -> Array<String> {
        var hyperlinkList: [String] = []
        var tagList: [String] = htmlString.componentsSeparatedByString("<")
        for tag in tagList {
            if (Regex("a ").test(tag)) {
//            if (Array(tag).count > 2 && Array(tag)[0] == "a" && Array(tag)[1] == " ") {
                println(tag)
                let matches = Regex("href='.*'").matches(tag);
                println(matches[0])
                hyperlinkList.append(tag)
            }
        }
        return hyperlinkList
    }
    
}



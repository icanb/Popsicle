//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var titleLabel: UILabel!

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
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("App Started")
        titleLabel.text = appDelegate.device?.uid
        
        let stringUrl:String = "http://google.com"
        cacheHtmlPages(stringUrl)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cacheHtmlPages(stringUrl: String) -> Void {
        let url = NSURL(string: stringUrl)
        
        // TODO: recursively get shit from links.
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            let response = NSString(data: data, encoding: NSUTF8StringEncoding)
            var hyperlinks = self.getHyperlinksFromHtml(response)
            println(hyperlinks)
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


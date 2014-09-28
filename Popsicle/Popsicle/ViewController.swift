//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet var tableView: UITableView!
    
    let cellIdentifier = "cellIdentifier"
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var sites:[SiteMetadata] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("App Started")

//        titleLabel.text = appDelegate.device?.uid
        
        let stringUrl:String = "http://google.com"
        cacheHtmlPages(stringUrl)

        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.sites = self.appDelegate.device!.cache
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Table Delegate methods
    
    // section setup
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    // cell setup
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0) {
            return self.sites.count
        }
        else {
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    
        var cell = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as UITableViewCell

        
        cell.textLabel?.text = self.sites[indexPath.row].hostname

        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
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


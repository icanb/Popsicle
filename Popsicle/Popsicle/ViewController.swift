//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StorageUpdateDelegate {
    
    @IBOutlet var tableView: UITableView!

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
    
    let serviceType = "popsicle"
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCBrowserViewController!
    
    let cellIdentifier = "cellIdentifier"
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var sites:[SiteMetadata] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("App Started")

//        titleLabel.text = appDelegate.device?.uid
        
        let stringUrl:String = "http://google.com"
//        cacheHtmlPages(stringUrl)

        
        // Configure the table
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView?.registerNib(UINib(nibName: "SiteCellView", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        self.sites = self.appDelegate.device!.cache
        self.appDelegate.device!.subscribeForUpdate(self, key: "current_device")
        
        // Initialize MC stuff
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        println("Peer ID is '\(self.peerID.displayName)'")
        
        self.session = MCSession(peer: self.peerID)
        
        var assistant = MCAdvertiserAssistant(serviceType: self.serviceType,
            discoveryInfo: nil, // we're gonna want to fux with this later on
            session: self.session)
        assistant.start()
        
        self.browser = MCBrowserViewController(serviceType: self.serviceType, session: self.session)
        
        self.presentViewController(self.browser, animated: false, completion: ({
            println("presentViewController dismissed");
        }))

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Table View setup
    
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 70
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0;
    }
    
    // Table Data Delegate methods
    
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
        
        var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as UITableViewCell

        if (cell == nil) {
            var nibs = NSBundle.mainBundle().loadNibNamed("SiteCellView", owner: self, options: nil)
            cell = nibs[0] as UITableViewCell
        }

        
        var image = UIImage(named: "site-cell-bg")
        var insets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
        image = image.resizableImageWithCapInsets(insets)
        
        var button:UIButton = cell.viewWithTag(2) as UIButton
        button.setBackgroundImage(image, forState: UIControlState.Normal)

        var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
        siteNameLabel?.text = self.sites[indexPath.row].hostname

        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }
    
        
    func storageUpdated(key:String) {
        
        if (key == "current_device") {
            self.sites = self.appDelegate.device!.cache
            self.tableView.reloadData()
        }

    }

}


//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StorageUpdateDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate {
    
    @IBOutlet var tableView: UITableView!

    var expandedIndex:NSIndexPath?

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
    var browser: MCNearbyServiceBrowser!
    
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
//        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView?.registerNib(UINib(nibName: "SiteCellView", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        self.sites = self.appDelegate.device!.cache
        self.appDelegate.device!.subscribeForUpdate(self, key: "current_device")
        
        // Initialize MC stuff
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        println("Peer ID is '\(self.peerID.displayName)'")
        
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        
        var assistant = MCAdvertiserAssistant(serviceType: self.serviceType,
            discoveryInfo: ["foo": "bar"], // we're gonna want to fux with this later on
            session: self.session)
        assistant.start()
        
        var browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    // MCNearbyServiceBrowserDelegate methods

    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        println(error)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject : AnyObject]!) {
        println("Found peer: \(peerID)")
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        println("Lost peer: \(peerID)")
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        println("PEER \(peerID) CHANGED STATE TO \(state)")
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        println("didRecieveData")
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        println("didRecieveStream")
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        println("didStartReceivingResourceWithName")
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        println("didFinishReceivingResourceWithName")
    }
    
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        println("didRecieveCertificate")
    }
    
    // Table View setup
    
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            
            if (self.expandedIndex == indexPath) {
                return 490
            }
    
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
            print(self.sites.count)
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
        
        var button:UIButtonForRow = cell.viewWithTag(2) as UIButtonForRow
        button.setBackgroundImage(image, forState: UIControlState.Normal)
        button.indexPath = indexPath
        button.addTarget(self, action: "siteTapped:", forControlEvents: .TouchUpInside)
        
        var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
        siteNameLabel?.text = self.sites[indexPath.row].hostname

        if (indexPath == expandedIndex) {
            var pagesTable:UITableView! = UITableView()

            pagesTable.hidden = false
            pagesTable.userInteractionEnabled = true
            var pagesViewController:PagesViewController = PagesViewController(site: self.sites[indexPath.row],table:pagesTable)
            pagesTable.delegate = pagesViewController
            pagesTable.dataSource = pagesViewController
            pagesTable.backgroundColor = UIColor.redColor()
            
            var tableFrame = cell.frame
            tableFrame.size.height = 300
            tableFrame.origin.y = 70
            pagesTable.frame = tableFrame

            cell.addSubview(pagesTable)
        }

        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        
        self.expandedIndex = indexPath
        self.tableView.reloadData()
    }
    
    func siteTapped(sender:UIButtonForRow!) {
       
        var indexPath:NSIndexPath? = sender.indexPath
        self.expandedIndex = indexPath
        self.tableView.reloadData()
    }
    
    func storageUpdated(key:String) {
        
        if (key == "current_device") {
            self.sites = self.appDelegate.device!.cache
            self.tableView.reloadData()
        }

    }

}


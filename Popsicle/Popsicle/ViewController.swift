//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StorageUpdateDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    @IBOutlet var tableView: UITableView!

    var expandedIndex:NSIndexPath?
    var selectedSite:SiteMetadata?
    var nmrPages = 0

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
    var advertiser: MCNearbyServiceAdvertiser!
    let discoveryInfoSitesKey = "sites"
    var remoteSites = [String: MCPeerID]()
    
    let cellIdentifier = "cellIdentifier"
    let cellIdentifierPage = "cellIdentifierPage"

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var localSites:[SiteMetadata] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("App Started")

//        titleLabel.text = appDelegate.device?.uid
        
        let stringUrl:String = "http://google.com"
//        cacheHtmlPages(stringUrl)

        
        // Configure the table
        self.tableView?.registerNib(UINib(nibName: "SiteCellView", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.tableView?.registerNib(UINib(nibName: "PageCellView", bundle: nil), forCellReuseIdentifier: cellIdentifierPage)
        
        self.localSites = self.appDelegate.device!.cache
        self.appDelegate.device!.subscribeForUpdate(self, key: "current_device")
        
        // Initialize MC stuff
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        println("Peer ID is '\(self.peerID.displayName)'")
        
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        
        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID,
            discoveryInfo: [discoveryInfoSitesKey: "example.com,example.org,example.edu"],
            serviceType: self.serviceType)
        self.advertiser.delegate = self
        self.advertiser.startAdvertisingPeer()
        
        self.browser = MCNearbyServiceBrowser(peer: self.peerID, serviceType: self.serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
    }
    
    func showAlert(message: NSString!) {
        println("showAlert(): \(message)")
//        UIAlertView(title: "MC", message: message, delegate: nil, cancelButtonTitle: "K.").show()
    }
    
    // Advertiser methods
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didNotStartAdvertisingPeer error: NSError!) {
        showAlert("did NOT start advertising")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        showAlert("Received invitation from peer!!")
    }
    
    // Browser methods
    
    func browser(browser: MCNearbyServiceBrowser!, didNotStartBrowsingForPeers error: NSError!) {
        showAlert("did NOT start browsing for peers")
        println(error)
    }
    
    func browser(browser: MCNearbyServiceBrowser!, foundPeer peerID: MCPeerID!, withDiscoveryInfo info: [NSObject: AnyObject]!) {
        if (peerID.displayName == UIDevice.currentDevice().name) {
            println("found ourselves... ignoring")
        } else {
            println(info)
            showAlert("Found peer: \(peerID)")
            if let infoDict = info as? Dictionary<String, String> {
                if (infoDict.indexForKey(discoveryInfoSitesKey) == nil) {
                    println("Remote peer's discovery info didn't have \(discoveryInfoSitesKey) key")
                    return
                }
                for remoteSite in infoDict[discoveryInfoSitesKey]!.componentsSeparatedByString(",") {
                    self.remoteSites[remoteSite] = peerID
                }
            }
            println("self.remoteSites: \(self.remoteSites)")
        }
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

        var cellType:String = getCellType(indexPath)

        if (cellType == "page") {
            return 40
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
        // Local caches
        if(section == 0) {
            print(self.localSites.count)
            var count:Int = self.localSites.count
            if (expandedIndex != nil) {
                count = count + self.nmrPages
            }

            return count
        }
        // Remote path
        else {
            var count = 0
            for remoteSite in remoteSites {
                println("remoteSite: \(remoteSite)")
                count += 1
            }
            return count
        }
    }
    
    // Unified way of determining the cell type
    // - localsite
    // - page
    // - remotesite
    func getCellType(indexPath:NSIndexPath) -> NSString {
        
        if (self.expandedIndex != nil &&
            indexPath.section == 0 &&
            indexPath.row > self.expandedIndex!.row && indexPath.row <= self.expandedIndex!.row + self.nmrPages) {
                return "page"
        }
        else if (indexPath.section == 0) {
            return "localsite"
        }
        else if (indexPath.section == 1) {
            return "remotesite"
        }
        
        return ""
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellType:String = getCellType(indexPath)


        if (cellType == "page") {
            
            // Page Cell

            var indexRow = indexPath.row
            indexRow = indexRow - self.expandedIndex!.row - 1
            print(indexRow)
            var page =  self.selectedSite?.pages[indexRow]

            var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifierPage) as UITableViewCell
            
            if (cell == nil) {
                var nibs = NSBundle.mainBundle().loadNibNamed("PageCellView", owner: self, options: nil)
                cell = nibs[0] as UITableViewCell
            }
            
            
            var image = UIImage(named: "site-cell-bg")
            var insets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
            image = image.resizableImageWithCapInsets(insets)

            var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
            siteNameLabel?.text = page?.url_path
    
            return cell
    
        }
        else if (cellType == "localsite") {
            // site cell
            var indexRow = indexPath.row
            
            if(self.expandedIndex != nil && indexRow > self.expandedIndex!.row) {
                indexRow = indexRow - self.nmrPages
            }
            
            var site =  self.localSites[indexRow]
            
            
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
            siteNameLabel?.text = site.hostname
            
            return cell

        }
        else if (cellType == "remotesite") {
            // remote
            
            // site cell
            var indexRow = indexPath.row
            
            if(self.expandedIndex != nil && indexRow > self.expandedIndex!.row) {
                indexRow = indexRow - self.nmrPages
            }
            
            var site = self.remoteSites.keys.array[indexRow]
            
            
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
            siteNameLabel?.text = site
            
            return cell
        }

        
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
        siteNameLabel?.text = self.localSites[indexPath.row].hostname

        if (indexPath == expandedIndex) {
            var pagesTable:UITableView! = cell.viewWithTag(3) as UITableView
            pagesTable.hidden = false
            pagesTable.userInteractionEnabled = true
            var pagesViewController:PagesViewController = PagesViewController(site: self.localSites[indexPath.row],table:pagesTable)
            pagesTable.delegate = pagesViewController
            pagesTable.dataSource = pagesViewController
            
//            var tableFrame = pagesTable.frame
//            tableFrame.size.height = tableFrame.size.height + 70
//            tableFrame.origin.y = tableFrame.origin.y - 70
//            pagesTable.frame = tableFrame

        }
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        
        self.expandedIndex = indexPath
        self.selectedSite = self.localSites[indexPath.row]
        self.nmrPages = self.selectedSite!.pages.count
        
        print(self.selectedSite?.pages)
        
        // disabled temporarily so the app doesn't crash
        self.tableView.reloadData()
        
//        showWebViewWithSite("http://www.yahoo.com")
    }
    
    func siteTapped(sender:UIButtonForRow!) {
        var indexPath:NSIndexPath? = sender.indexPath
        self.expandedIndex = indexPath
        self.tableView.reloadData()
    }
    
    func storageUpdated(key:String) {
        
        if (key == "current_device") {
            self.localSites = self.appDelegate.device!.cache
            self.tableView.reloadData()
        }

    }
    
    func showWebViewWithSite(URL: String) {
        let webViewController = self.storyboard?.instantiateViewControllerWithIdentifier("offlineWebViewController") as OfflineWebViewController
        webViewController.initialURL = URL
        self.navigationController?.pushViewController(webViewController, animated: true)
    }

}


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

//        [[UINavigationBar appearance] setTitleTextAttributes:
//            [NSDictionary dictionaryWithObjectsAndKeys:
//            [UIColor blackColor], UITextAttributeTextColor,
//            [UIFont fontWithName:@"ArialMT" size:16.0], UITextAttributeFont,nil]];
//
//        UIBarButtonItem.appearance().tintColor = UIColor.magentaColor()
//        UINavigationBar.appearance().titleTextAttributes = [UITextAttributeTextColor: UIColor.blueColor()]


        
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
        
        println("Peers:")
        println(self.session.connectedPeers)
        
        var toBroadcast:[String] = []
        for site in localSites {
            toBroadcast.append(site.hostname)
        }

        self.advertiser = MCNearbyServiceAdvertiser(peer: self.peerID,
            discoveryInfo: [discoveryInfoSitesKey: ",".join(toBroadcast)],
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
        
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: context)
        let remotePeerDisplayName = unarchiver.decodeObjectForKey("displayName") as String!
        let requestedHostname = unarchiver.decodeObjectForKey("hostname") as String!
        
        var alertController = UIAlertController(title: "Request from \(remotePeerDisplayName)", message: "Share \(requestedHostname)?", preferredStyle: UIAlertControllerStyle.Alert)
        var acceptAction = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) in
            println("We want to ACCEPT")
            invitationHandler(true, self.session)
            
        })
        var rejectAction = UIAlertAction(title: "Reject", style: UIAlertActionStyle.Cancel, handler: {(UIAlertAction) in
            println("We want to REJECT")
            
            invitationHandler(false, self.session)
        })
        alertController.addAction(rejectAction)
        alertController.addAction(acceptAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
            self.tableView.reloadData()
            println("self.remoteSites: \(self.remoteSites)")
        }
    }
    
    func browser(browser: MCNearbyServiceBrowser!, lostPeer peerID: MCPeerID!) {
        println("Lost peer: \(peerID)")
        for (remoteHostname, remotePeerID) in self.remoteSites {
            println("Looking at \(remoteHostname) - \(remotePeerID)")
            if (remotePeerID == peerID) {
                self.remoteSites.removeValueForKey(remoteHostname)
                println("Removed \(remoteHostname) - \(remotePeerID))")
            }
        }
        self.tableView.reloadData()
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        if (state == MCSessionState.Connected) {
            println("Connected to peer \(peerID)!")
        }
        else if (state == MCSessionState.Connecting) {
            println("Connecting... to peer \(peerID)")
        }
        else if (state == MCSessionState.NotConnected) {
            println("Disconnected from peer \(peerID)")
        } else {
            println("Unknown state change for peer \(peerID)")
        }
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
        
        return 64
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0;
    }
    
    // Table Data Delegate methods
    
    // section setup
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        if (section == 0) {
            return "AVAILABLE PAGES"
        }
        else {
            return "PAGES AROUND"
        }
    }

    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var title = ""
        if (section == 0) {
            title = "AVAILABLE PAGES"
        }
        else {
            title = "PAGES AROUND"
        }

        
        var view:UIView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 18))
        
        var label:UILabel = UILabel(frame: CGRectMake(8, 2, tableView.frame.size.width, 18))
        
        label.font = UIFont.systemFontOfSize(10)
        label.text = title
        view.addSubview(label)
        view.backgroundColor = UIColor.clearColor()
    
        return view
        
        
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
//        /* Create custom view to display section header... */
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
//        [label setFont:[UIFont boldSystemFontOfSize:12]];
//        NSString *string =[list objectAtIndex:section];
//        /* Section header is in 0th index... */
//        [label setText:string];
//        [view addSubview:label];
//        [view setBackgroundColor:[UIColor colorWithRed:166/255.0 green:177/255.0 blue:186/255.0 alpha:1.0]]; //your background color...
//        return view;
        
        
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
            return remoteSites.count
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

    func getPageWithIndexRow(indexPath:NSIndexPath) -> PageCache? {
        var indexRow = indexPath.row
        indexRow = indexRow - self.expandedIndex!.row - 1
        print(indexRow)
        return self.selectedSite?.pages[indexRow]
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cellType:String = getCellType(indexPath)


        if (cellType == "page") {
            
            // Page Cell
            var page = getPageWithIndexRow(indexPath)

            var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifierPage) as UITableViewCell
            
            if (cell == nil) {
                var nibs = NSBundle.mainBundle().loadNibNamed("PageCellView", owner: self, options: nil)
                cell = nibs[0] as UITableViewCell
            }
            
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None

            var image = UIImage(named: "full-page-cell")
            var insets = UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
            image = image.resizableImageWithCapInsets(insets)
            
            var cellFrame = cell.frame
            cellFrame.size.width = tableView.frame.size.width
            cell.frame = cellFrame

            var button:UIButtonForRow = cell.viewWithTag(2) as UIButtonForRow
            button.indexPath = indexPath
            
            var buttonFrame = button.frame
            buttonFrame.size.width = cell.frame.size.width - 8
            buttonFrame.origin.x = 4
            button.frame = buttonFrame
            button.setBackgroundImage(image, forState: UIControlState.Normal)

            
            var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
            siteNameLabel?.text = page?.title

            return cell
    
        }
        else {
            
            var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.cellIdentifier) as UITableViewCell
            
            if (cell == nil) {
                var nibs = NSBundle.mainBundle().loadNibNamed("SiteCellView", owner: self, options: nil)
                cell = nibs[0] as UITableViewCell
            }

            var image = UIImage(named: "full-site-cell")
            var insets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
            image = image.resizableImageWithCapInsets(insets)


            var cellFrame = cell.frame
            cellFrame.size.width = tableView.frame.size.width
            cell.frame = cellFrame
            
            var button:UIButtonForRow = cell.viewWithTag(2) as UIButtonForRow
            button.setBackgroundImage(image, forState: UIControlState.Normal)
            button.indexPath = indexPath

            if (indexPath == expandedIndex) {
                var imageTop = UIImage(named: "top-site-cell")
                var insetsTop = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 0.0, right: 12.0)
                imageTop = imageTop.resizableImageWithCapInsets(insetsTop)
                button.setBackgroundImage(imageTop, forState: UIControlState.Normal)
            }
    
            var buttonFrame = button.frame
            buttonFrame.size.width = cell.frame.size.width - 8
            buttonFrame.origin.x = 4
            button.frame = buttonFrame

            var indexRow = indexPath.row

            cell.selectionStyle = UITableViewCellSelectionStyle.None

            if (cellType == "localsite") {
                // site cell
            
                if(self.expandedIndex != nil && indexRow > self.expandedIndex!.row) {
                    indexRow = indexRow - self.nmrPages
                }
            
                var site =  self.localSites[indexRow]
            
            
                var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
                siteNameLabel?.text = site.hostname
            
                return cell
            }
            else {
                // remote site cell
                var remoteSite = self.remoteSites.keys.array[indexRow]
                
                var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
                siteNameLabel?.text = remoteSite
                
                return cell
            }

        }

    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        
        var cellType:String = getCellType(indexPath)

        if (cellType == "page")  {
            // Open the page here
            var page = getPageWithIndexRow(indexPath)
//            var sm:StorageManager = self.appDelegate.getStorageManager()
//            var site = sm.getSiteWithHostname(host: page.)
            var indexRow = indexPath.row
            indexRow = indexRow - self.expandedIndex!.row - 1
            println(self.localSites)
//            var site =  self.localSites[indexRow]
            self.showWebViewWithSite(page!, site: self.selectedSite!)

        }
        else if (cellType == "remotesite") {
            let remotePeerID = self.remoteSites.values.array[indexPath.row]
            let requestedHostname = self.remoteSites.keys.array[indexPath.row]
            
            println("Sending invitation to \(remotePeerID) for \(requestedHostname)!")
            
            let contextDict = ["displayName": self.peerID.displayName, "hostname": requestedHostname]
            
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(remotePeerID.displayName, forKey: "displayName")
            archiver.encodeObject(requestedHostname, forKey: "hostname")
            archiver.finishEncoding()
            
            self.browser.invitePeer(remotePeerID, toSession: self.session, withContext: data, timeout: 0)
        }
        else {
            
            if (self.expandedIndex == nil) {
                // nothing is expanded
                self.expandedIndex = indexPath
                self.selectedSite = self.localSites[indexPath.row]
                self.nmrPages = self.selectedSite!.pages.count
            }
            else if (self.expandedIndex == indexPath) {
                // tapped on already expanded
                self.expandedIndex = nil
                self.selectedSite = nil
                self.nmrPages = 0
            }
            else {
                // tapped on a different site
                self.expandedIndex = indexPath
                self.selectedSite = self.localSites[indexPath.row]
                self.nmrPages = self.selectedSite!.pages.count
            }
            
            self.tableView.reloadData()
        }

        
        print(self.selectedSite?.pages)
        
        // disabled temporarily so the app doesn't crash
        self.tableView.reloadData()
        
//        showWebViewWithSite("http://www.yahoo.com")
    }
    
    func storageUpdated(key:String) {
        
        if (key == "current_device") {
            self.localSites = self.appDelegate.device!.cache
            self.tableView.reloadData()
        }

    }
    
    func showWebViewWithSite(page: PageCache, site: SiteMetadata) {
        println("showwebview goddamnit")
        let webViewController = self.storyboard?.instantiateViewControllerWithIdentifier("offlineWebViewController") as OfflineWebViewController
        webViewController.initialPage = page
        webViewController.rooSite = site
        self.navigationController?.pushViewController(webViewController, animated: true)
    }

}


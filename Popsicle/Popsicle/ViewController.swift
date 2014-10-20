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
    @IBOutlet var customNavigationView: UIView!
    
    var expandedIndex:NSIndexPath?
    var selectedSite:SiteMetadata?
    var nmrPages = 0
    var nuxView:UIView?
    
    let serviceType = "popsicle"
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCNearbyServiceBrowser!
    var advertiser: MCNearbyServiceAdvertiser!
    let discoveryInfoSitesKey = "sites"
    var remoteSites = [String: MCPeerID]()
    var toSendWhenReady: SiteMetadata?
    var currentlySpinning: UIActivityIndicatorView?
    
    let cellIdentifier = "cellIdentifier"
    let cellIdentifierPage = "cellIdentifierPage"
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var localSites:[SiteMetadata] = []
    
    var layoutConstraintsLandscape:NSLayoutConstraint?
    var layoutConstraintsPortrait:NSLayoutConstraint?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if !userCompletedTour() {
            let subviewArray = NSBundle.mainBundle().loadNibNamed("NUXView", owner: self, options: nil)
            self.nuxView = subviewArray[0] as? UIView
            self.nuxView?.frame = self.view.frame
            var button:UIButton = self.nuxView!.viewWithTag(1) as UIButton
            button.addTarget(self, action: Selector("hideNUX"), forControlEvents: .TouchUpInside)
            self.view.addSubview(self.nuxView!)
            
        }
        
        
        self.layoutConstraintsLandscape = NSLayoutConstraint(
            item: self.customNavigationView!,
            attribute: NSLayoutAttribute.Height,
            relatedBy:NSLayoutRelation.Equal,
            toItem: nil,
            attribute:NSLayoutAttribute.NotAnAttribute,
            multiplier:1.0,
            constant:38.0
        )
        
        self.layoutConstraintsPortrait = NSLayoutConstraint(
            item: self.customNavigationView!,
            attribute: NSLayoutAttribute.Height,
            relatedBy:NSLayoutRelation.Equal,
            toItem: nil,
            attribute:NSLayoutAttribute.NotAnAttribute,
            multiplier:1.0,
            constant:58.0
        )
        
        self.customNavigationView.addConstraint(self.layoutConstraintsPortrait!)
        
    }

    
    func userCompletedTour() -> Bool {
        var aVal:String? = NSUserDefaults.standardUserDefaults().objectForKey("aValue") as String?
        return aVal == "1"
    }
    
    
    func hideNUX() {
        
        NSUserDefaults.standardUserDefaults().setObject("1", forKey:"aValue")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if (self.nuxView != nil) {
            self.nuxView!.removeFromSuperview()
        }
    }
    
    func showAlert(message: NSString!) {
        println("showAlert(): \(message)")
        UIAlertView(title: "MC", message: message, delegate: nil, cancelButtonTitle: "K.").show()
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
            // Step 1: Immediately reply "yes"
            invitationHandler(true, self.session)
            // Step 2:
            self.toSendWhenReady = self.getLocalSite(requestedHostname)
            
            println("When ready, will send \(self.toSendWhenReady)")
            
        })
        var rejectAction = UIAlertAction(title: "Reject", style: UIAlertActionStyle.Cancel, handler: {(UIAlertAction) in
            println("We want to REJECT")
            
            invitationHandler(false, self.session)
        })
        alertController.addAction(rejectAction)
        alertController.addAction(acceptAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
            println("Found peer: \(peerID)")
            if let infoDict = info as? Dictionary<String, String> {
                if (infoDict.indexForKey(discoveryInfoSitesKey) == nil) {
                    println("Remote peer's discovery info didn't have \(discoveryInfoSitesKey) key")
                    return
                }
                for remoteSite in infoDict[discoveryInfoSitesKey]!.componentsSeparatedByString(",") {
                    println(remoteSite)
                    if (countElements(remoteSite) > 0) {
                        self.remoteSites[remoteSite] = peerID
                    }
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
    
    func getLocalSite(hostname: String!) -> SiteMetadata? {
        for localSite in self.localSites {
            if (localSite.hostname == hostname) {
                return localSite
            }
        }
        return nil
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        if (state == MCSessionState.Connected) {
            println("Connected to peer \(peerID)!")
            if let toSend = self.toSendWhenReady {
                println("The time has come the walrus said!")
                var data = NSKeyedArchiver.archivedDataWithRootObject(toSend)
                
                var error : NSError?
                
                self.session.sendData(data, toPeers: [peerID],
                    withMode: MCSessionSendDataMode.Reliable, error: &error)
                
                if error != nil {
                    print("Error sending data: \(error?.localizedDescription)")
                }
                
            }
        }
        else if (state == MCSessionState.Connecting) {
            println("Connecting... to peer \(peerID)")
        }
        else if (state == MCSessionState.NotConnected) {
            println("Disconnected from peer \(peerID)")
            self.currentlySpinning?.hidden = true
            self.currentlySpinning?.stopAnimating()
        } else {
            println("Unknown state change for peer \(peerID)")
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        println("recieved data from \(peerID.displayName)!")
        let recievedSite = NSKeyedUnarchiver.unarchiveObjectWithData(data) as SiteMetadata
        
        self.appDelegate.device!.cache.append(recievedSite)
        self.appDelegate.device!.updateStorage()
        self.session.disconnect()
        self.currentlySpinning?.hidden = true
        self.currentlySpinning?.stopAnimating()
        self.currentlySpinning = nil
    }
    
    // Not used
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        println("didRecieveStream")
    }
    
    // Not used
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        println("didStartReceivingResourceWithName")
    }
    
    // Not used
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        println("didFinishReceivingResourceWithName")
    }
    
    // Not used, but apparently gets called sometimes
    func session(session: MCSession!, didReceiveCertificate certificate: [AnyObject]!, fromPeer peerID: MCPeerID!, certificateHandler: ((Bool) -> Void)!) {
        // security level >9000
        certificateHandler(true)
    }
    
    // Table View setup
    
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            
            var cellType:String = getCellType(indexPath)
            
            if (cellType == "page") {
                if (self.expandedIndex != nil &&
                    indexPath.row == self.expandedIndex!.row + self.nmrPages) {
                        return 44
                }
                return 40
            }
            
            if (indexPath == expandedIndex) {
                return 60
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
        
        
        var view:UIView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 38))
        
        var label:UILabel = UILabel(frame: CGRectMake(20, 2, tableView.frame.size.width, 38))
        
        label.font = UIFont(name: "Avenir", size: CGFloat(11))
        
        label.text = title
        view.addSubview(label)
        view.backgroundColor = UIColor.clearColor()
        
        return view
        
    }
    
    // cell setup
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Local caches
        if(section == 0) {
            if (self.localSites.count == 0) {
                return 1
            }
            
            var count:Int = self.localSites.count + self.nmrPages
            
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
        
        if(self.selectedSite?.pages.count > indexRow) {
            return self.selectedSite?.pages[indexRow]
        }
        else {
            return nil
        }
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
            buttonFrame.size.width = cell.frame.size.width - 12
            buttonFrame.origin.x = 6
            button.frame = buttonFrame
            button.setBackgroundImage(image, forState: UIControlState.Normal)
            
            if (indexPath.row == self.expandedIndex!.row + self.nmrPages) {
                var imageBottom = UIImage(named: "bottom-page-cell")
                var insetsBottom = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
                imageBottom = imageBottom.resizableImageWithCapInsets(insetsBottom)
                button.setBackgroundImage(imageBottom, forState: UIControlState.Normal)
            }
            
            
            var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
            
            if (page == nil) {
                siteNameLabel?.text = "No pages available"
            }
            else {
                siteNameLabel?.text = page?.title
            }
            
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
            
            var bgButton:UIButtonForRow = cell.viewWithTag(2) as UIButtonForRow
            bgButton.setBackgroundImage(image, forState: UIControlState.Normal)
            bgButton.indexPath = indexPath
            
            
            
            if (indexPath == expandedIndex) {
                var imageTop = UIImage(named: "top-site-cell")
                var insetsTop = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 0.0, right: 12.0)
                imageTop = imageTop.resizableImageWithCapInsets(insetsTop)
                bgButton.setBackgroundImage(imageTop, forState: UIControlState.Normal)
            }
            
            var buttonFrame = bgButton.frame
            buttonFrame.size.width = cell.frame.size.width - 12
            buttonFrame.origin.x = 6
            bgButton.frame = buttonFrame
            
            var indexRow = indexPath.row
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            if (cellType == "localsite") {
                
                var settingsButton:UIButtonForRow = cell.viewWithTag(7) as UIButtonForRow
                settingsButton.indexPath = indexPath
                settingsButton.addTarget(self, action: Selector("showSettingsForSite:"), forControlEvents: .TouchUpInside)

                
                var settingsBtnFrame = settingsButton.frame;
                settingsBtnFrame.origin.x =  bgButton.frame.size.width - 45
                settingsButton.frame = settingsBtnFrame
                // bind the event here
                
                if (indexPath == expandedIndex) {
                    settingsButton.hidden = false;
                }
                else {
                    settingsButton.hidden = true;
                }
                
                // site cell
                var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
                var lastUpdatedLabel:UILabel! = cell.viewWithTag(6) as UILabel
                var noSiteLabel:UILabel! = cell.viewWithTag(3) as UILabel
                
                
                var labelFrame = siteNameLabel.frame
                labelFrame.size.width = bgButton.frame.size.width - 60;
                siteNameLabel.frame = labelFrame
                
                if (self.localSites.count == 0) {
                    siteNameLabel.hidden = true
                    lastUpdatedLabel.hidden = true
                    noSiteLabel.hidden = false
                    return cell
                }
                else {
                    siteNameLabel.hidden = false
                    lastUpdatedLabel.hidden = false
                    noSiteLabel.hidden = true
                }
                
                if(self.expandedIndex != nil && indexRow > self.expandedIndex!.row) {
                    indexRow = indexRow - self.nmrPages
                }
                
                var site =  self.localSites[indexRow]
                siteNameLabel?.text = site.hostname
                lastUpdatedLabel?.text = getAgoString(site.last_update)
                
                return cell
            }
            else {
                // remote site cell
                var remoteSite = self.remoteSites.keys.array[indexRow]
                var deviceName = self.remoteSites[remoteSite]?.displayName
                
                var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
                var deviceNameLabel:UILabel! = cell.viewWithTag(6) as UILabel
                
                siteNameLabel?.text = remoteSite
                deviceNameLabel?.text = deviceName
                
                return cell
            }
            
        }
        
    }
    
    func getAgoString(when:NSDate) -> String {
        
        var now:NSDate = NSDate();
        var interval:NSTimeInterval = when.timeIntervalSinceNow
        
        var second = 1;
        var minute = second*60;
        var hour = minute*60;
        var day = hour*24;
        
        // interval can be before (negative) or after (positive)
        var num = abs(Int(interval))
        var unit = "day";
        
        if (num <= 20) {
            return "Updated just now"
        }
        if (num >= day) {
            num /= day;
            if (num > 1) { unit = "days" };
        } else if (num >= hour) {
            num /= hour;
            unit = (num > 1) ? "hours" : "hour";
        } else if (num >= minute) {
            num /= minute;
            unit = (num > 1) ? "minutes" : "minute";
        } else if (num >= second) {
            num /= second;
            unit = (num > 1) ? "seconds" : "second";
        }
        
        return NSString(format:"Updated %d %@ ago", num, unit);
    }
    
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        
        var cellType:String = getCellType(indexPath)
        
        if (cellType == "page")  {
            // Open the page here
            var page = getPageWithIndexRow(indexPath)
            var indexRow = indexPath.row
            indexRow = indexRow - self.expandedIndex!.row - 1

            self.showWebViewWithSite(page!, site: self.selectedSite!)
        }
        else if (cellType == "remotesite") {
            let remotePeerID = self.remoteSites.values.array[indexPath.row]
            let requestedHostname = self.remoteSites.keys.array[indexPath.row]
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            self.currentlySpinning = cell?.viewWithTag(4) as UIActivityIndicatorView
            self.currentlySpinning!.hidden = false
            self.currentlySpinning!.startAnimating()
            
            dispatch_async(dispatch_get_main_queue(), {
                self.currentlySpinning!.startAnimating()
            })
            
            println("Sending invitation to \(remotePeerID) for \(requestedHostname)!")
            
            let contextDict = ["displayName": self.peerID.displayName, "hostname": requestedHostname]
            
            let data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            archiver.encodeObject(self.peerID.displayName, forKey: "displayName")
            archiver.encodeObject(requestedHostname, forKey: "hostname")
            archiver.finishEncoding()
            
            self.browser.invitePeer(remotePeerID, toSession: self.session, withContext: data, timeout: 0)
            self.tableView.reloadData()
        }
        else {
            
            if (self.expandedIndex == nil) {
                // nothing is expanded
                
                if (self.localSites.count == 0) {
                    return;
                }
                
                self.expandedIndex = indexPath
                self.selectedSite = self.localSites[indexPath.row]
                
                expandSite(self.selectedSite!, atIndex: indexPath)
                
                return;
            }
            else if (self.expandedIndex == indexPath) {
                
                // tapped on already expanded
                // delete the old rows
                
                shrinkSite(indexPath)

                return;
            }
            else {
                // tapped on a different site
                // delete the old rows
                // insert new rows
                var prevNmrPages = self.nmrPages;
                var expIndexInt = indexPath.row
                if (indexPath.row >= self.expandedIndex!.row + self.nmrPages) {
                    expIndexInt = indexPath.row - prevNmrPages
                }

                
                shrinkSite(self.expandedIndex!)
                
                // start expanding
                self.expandedIndex = NSIndexPath(forRow: expIndexInt, inSection: indexPath.section)
                self.selectedSite = self.localSites[expIndexInt]

                expandSite(self.selectedSite!, atIndex: self.expandedIndex!)

                return;
                
            }

        }
        
    }
    
    func expandSite(site: SiteMetadata, atIndex indexPath:NSIndexPath) {
        
        self.nmrPages = getNumberOfPages(self.selectedSite!)
        
        if (self.nmrPages == 0) {
            // if there are not pages, we need to show
            // no pages text
            self.nmrPages = 1;
        }
        
        var expIndexInt = indexPath.row
        var indexes:[NSIndexPath] = []
        for ind in expIndexInt+1...expIndexInt+self.nmrPages {
            println(ind)
            indexes.append(NSIndexPath(forRow:ind, inSection:0))
        }
        
        self.tableView.insertRowsAtIndexPaths(indexes,
            withRowAnimation: UITableViewRowAnimation.Fade)
        
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:expIndexInt, inSection:0)],
            withRowAnimation: UITableViewRowAnimation.Fade)
    }
    

    func shrinkSite(indexPath:NSIndexPath) {

        var expIndexInt = indexPath.row
        var indexes:[NSIndexPath] = []
        
        for ind in expIndexInt+1...(expIndexInt+self.nmrPages) {
            indexes.append(NSIndexPath(forRow:ind, inSection:0))
        }

        self.expandedIndex = nil
        self.selectedSite = nil
        self.nmrPages = 0
        
        self.tableView.deleteRowsAtIndexPaths(indexes,
            withRowAnimation: UITableViewRowAnimation.Fade)

        
        self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow:expIndexInt, inSection:0)],
            withRowAnimation: UITableViewRowAnimation.Fade)

    }
    

    func getNumberOfPages(site: SiteMetadata) -> Int {
        
        var nmrPages = 0
        
        nmrPages = site.pages.count
        
        if (nmrPages > 10)  {
            nmrPages = 10
        }
        
        return nmrPages
    }


    func storageUpdated(key:String) {
        
        if (key == "current_device") {
            self.localSites = self.appDelegate.device!.cache
            
            if !contains(localSites, self.selectedSite!) {
                self.selectedSite = nil;
                self.nmrPages = 0
            }

            self.tableView.reloadData()
        }
        
    }


    func showSettingsForSite(sender: UIButtonForRow) {

        var row = sender.indexPath!.row
        var site = self.localSites[row]
        
        
        let siteSettingsModalViewController:SiteSettingsModalViewController = self.storyboard?.instantiateViewControllerWithIdentifier("siteSettingsModalViewController") as SiteSettingsModalViewController
        siteSettingsModalViewController.setSite(site)

        self.presentViewController(siteSettingsModalViewController, animated:true, completion: nil)

    }


    func showWebViewWithSite(page: PageCache, site: SiteMetadata) {
        
        let webViewController:OfflineWebViewController = self.storyboard?.instantiateViewControllerWithIdentifier("offlineWebViewController") as OfflineWebViewController
        
        webViewController.initialPage = page
        webViewController.rooSite = site
        
        self.presentViewController(webViewController, animated:true, completion: nil)
        
    }
    


    
    /* Handle Rotation */
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let transitionToWide = size.width > size.height
        
        if (transitionToWide){
            customNavigationView.addConstraint(layoutConstraintsLandscape!)
            customNavigationView.removeConstraint(layoutConstraintsPortrait!)
        }
        else {
            customNavigationView.addConstraint(layoutConstraintsPortrait!)
            customNavigationView.removeConstraint(layoutConstraintsLandscape!)
        }
        
        self.tableView.reloadData()
    }
    
    
    
}


//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, StorageUpdateDelegate {
    

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

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            var pagesTable:UITableView! = cell.viewWithTag(3) as UITableView
            pagesTable.hidden = false
            pagesTable.userInteractionEnabled = true
            pagesTable.delegate = PagesViewController(site: self.sites[indexPath.row],table:pagesTable)

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


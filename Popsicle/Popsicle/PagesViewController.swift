//
//  PagesViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/28/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import Foundation
import UIKit

class PagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var site:SiteMetadata?
    var tableView:UITableView?
    let cellIdentifier = "siteCellIdentifier"

    init(site:SiteMetadata, table: UITableView) {
        super.init()
        self.site = site
        self.tableView = table
        // Configure the table

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //Code to be removed from your destinationViewController
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Here you can init your properties
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the table
        self.tableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.cellIdentifier)

    }
    
    
    // Table View setup
    
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 42
    }
    
    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0;
    }
    
    // Table Data Delegate methods
    
    // section setup
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // cell setup
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.site!.pages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 2
        let cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: nil)
        
        
        // 5
        cell.textLabel?.text = "test"
        

//        var image = UIImage(named: "site-cell-bg")
//        var insets = UIEdgeInsets(top: 12.0, left: 12.0, bottom: 12.0, right: 12.0)
//        image = image.resizableImageWithCapInsets(insets)
//        
//        var button:UIButtonForRow = cell.viewWithTag(2) as UIButtonForRow
//        button.setBackgroundImage(image, forState: UIControlState.Normal)
//        button.indexPath = indexPath
//        button.addTarget(self, action: "siteTapped:", forControlEvents: .TouchUpInside)
//        
//        var siteNameLabel:UILabel! = cell.viewWithTag(1) as UILabel
//        siteNameLabel?.text = self.sites[indexPath.row].hostname
        
        return cell
    }
//    
//    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        println("You selected cell #\(indexPath.row)!")
//        
////        self.expandedIndex = indexPath
//        self.tableView.reloadData()
//    }

    
    
}

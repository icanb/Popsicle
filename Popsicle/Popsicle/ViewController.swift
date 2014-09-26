//
//  ViewController.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NSLog("App Started")
        
        let site_metadata_1 = SiteMetadata()
        site_metadata_1.port = 30
        print(site_metadata_1.port)
        let encoded_metadata = NSKeyedArchiver()
        site_metadata_1.encodeWithCoder(encoded_metadata)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


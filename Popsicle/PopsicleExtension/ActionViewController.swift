//
//  ActionViewController.swift
//  PopsicleExtension
//
//  Created by Takumi on 9/27/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit
import MobileCoreServices
import Foundation

class ActionViewController: UIViewController {
    @IBOutlet weak var textView: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.textView.text = "\(self.extensionContext!.inputItems)"
        
        var world = "Hello"
        NSLog("test: %@", world)
        
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        for item: AnyObject in self.extensionContext!.inputItems {
            let inputItem = item as NSExtensionItem
            for provider: AnyObject in inputItem.attachments! {
                let itemProvider = provider as NSItemProvider
                itemProvider.loadItemForTypeIdentifier(kUTTypePropertyList as NSString, options: nil, completionHandler: { (item, error) in
                    var results = item as NSDictionary
                    var baseURI = results.objectForKey(NSExtensionJavaScriptPreprocessingResultsKey)?.objectForKey("baseURI")
                    
                    println("\(baseURI)")
                    self.textView.text = "\(baseURI)"
                    println("js callback")
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequestReturningItems(self.extensionContext!.inputItems, completionHandler: nil)
    }

}

//
//  AppDelegate.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/26/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var device: Device?
    var storageManager:StorageManager?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String

        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var storePath = documentsPath.stringByAppendingPathComponent("/device_self_file2.sickle")
        var checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(storePath))
        {
            // FILE AVAILABLE
            var device_data:Device = NSKeyedUnarchiver.unarchiveObjectWithFile(storePath) as Device
            self.device = device_data
            self.device!.storePath = storePath

            print(device_data)
            print(device_data.cache)
        }
        else
        {   
            // FILE NOT AVAILABLE
            var new_device_data = Device()
            new_device_data.uid = UIDevice.currentDevice().name
            new_device_data.storePath = storePath

            var data = NSKeyedArchiver.archivedDataWithRootObject(new_device_data)
            data.writeToFile(storePath, atomically: true)
            
            self.device = new_device_data
        }
        
        self.storageManager = StorageManager(device: self.device!)
        
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let targetURL:String = getTargetURL(url)
        
        var newUrlComponents:NSURLComponents = NSURLComponents.componentsWithString(targetURL)
//        var isNew:Bool? = self.storageManager?.saveSite(host: newUrlComponents.host, port: newUrlComponents.port?.stringValue)
        self.storageManager?.savePage(host: newUrlComponents.host,
                                        port: newUrlComponents.port?.stringValue,
                                        full_url: url.absoluteString,
                                        parameters: [],
                                        title: "TEST TITLE",
                                        html: "TEST HTML")
        
        return true
    }
    
    func getTargetURL(url: NSURL) -> String {
        var strURL = (url.absoluteString!).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        return (strURL).substringFromIndex(advance(strURL.startIndex, 11)) // get rid of "Popsicle://"
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func showAlert(str:String) {
        println("asdfasdfasfasdfasfasdfa")
        var alert = UIAlertView(title: "yeah", message: str, delegate: self, cancelButtonTitle: "ok")
        alert.show()
    }


}


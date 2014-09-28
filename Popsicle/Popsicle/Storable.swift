//
//  Storable.swift
//  Popsicle
//
//  Created by Ilter Canberk on 9/27/14.
//  Copyright (c) 2014 hax. All rights reserved.
//

import Foundation

class Storable:NSObject {

    var storePath: String?
    var updateSubscribers:[(StorageUpdateDelegate, String)] = []
    
    func updateStorage() {
        if (storePath == nil) {
            println("No store path")
            return
        }
        
        var data = NSKeyedArchiver.archivedDataWithRootObject(self)
        data.writeToFile(self.storePath!, atomically: true)
        
        // update all the listeners
        for tuple in self.updateSubscribers {
            tuple.0.storageUpdated(tuple.1)
        }
    }
    
    
    func subscribeForUpdate(obj:StorageUpdateDelegate, key:String)  {
        var tuple = (obj:obj, key:key)
        self.updateSubscribers.append((obj, key))
    }

}

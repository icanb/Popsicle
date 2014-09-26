// Playground - noun: a place where people can play

import UIKit
import Foundation;


class SiteMetadata : NSObject, NSCoding {
    
    var hostname:String = ""
    var port = 80
    var last_update: NSDate = NSDate.date()
    var directory_path:String = "/"

    
    override init() {
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        self.init()
        
        self.hostname = aDecoder.decodeObjectForKey("hostname") as String!
        self.port = aDecoder.decodeIntegerForKey("port")
        self.last_update = aDecoder.decodeObjectForKey("last_update") as NSDate
        self.directory_path = aDecoder.decodeObjectForKey("directory_path") as String!

    }
    

    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(self.hostname, forKey:"hostname")
        aCoder.encodeInteger(30, forKey:"port")
        aCoder.encodeObject(self.last_update, forKey:"last_update")
        aCoder.encodeObject(self.directory_path, forKey:"directory_path")

    }
    
}

class PageCache : NSObject, NSCoding {

    var full_url: String = ""
    var url_path: String = ""
    var parameters: [String] = []
    var last_update:NSDate = NSDate.date()
    var site: SiteMetadata?

    override init() {
        super.init()
        self.site = nil
    }

    required convenience init(coder aDecoder: NSCoder) {

        self.init()

        self.full_url = aDecoder.decodeObjectForKey("full_url") as String!
        self.url_path = aDecoder.decodeObjectForKey("url_path") as String!
        self.parameters = aDecoder.decodeObjectForKey("parameters") as [String]
        self.last_update = aDecoder.decodeObjectForKey("last_update") as NSDate!
        self.site = aDecoder.decodeObjectForKey("site") as SiteMetadata!
    }
    
    func encodeWithCoder(aCoder: NSCoder) {

        aCoder.encodeObject(self.full_url, forKey:"full_url")
        aCoder.encodeObject(self.url_path, forKey:"url_path")
        aCoder.encodeObject(self.parameters, forKey:"parameters")
        aCoder.encodeObject(self.last_update, forKey:"last_update")
        if (self.site != nil) {
            aCoder.encodeObject(self.site!, forKey:"site")
        }
    }
}

class Device : NSObject, NSCoding {

    var uid: String = ""
    var name: String = ""
    var cache: [SiteMetadata] = []
    
    override init() {
        super.init()
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        self.init()

        self.uid = aDecoder.decodeObjectForKey("uid") as String!
        self.name = aDecoder.decodeObjectForKey("name") as String!
        self.cache = aDecoder.decodeObjectForKey("cache") as [SiteMetadata]
    }

    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.uid, forKey:"uid")
        aCoder.encodeObject(self.name, forKey:"name")
        aCoder.encodeObject(self.cache, forKey:"cache")
    }

    
}


func main () {


    var site_metadata_1 = SiteMetadata()
    site_metadata_1.port = 30

    var data = NSKeyedArchiver.archivedDataWithRootObject(site_metadata_1)
    NSUserDefaults.standardUserDefaults().setObject(data, forKey: "testSiteMetadata")
    
    
    if let reData = NSUserDefaults.standardUserDefaults().objectForKey("testSiteMetadata") as? NSData {
        let site_metadata_2 = NSKeyedUnarchiver.unarchiveObjectWithData(reData) as SiteMetadata
        print(site_metadata_2.port)
        print(site_metadata_2.last_update)
    }

    
    var page_metadata_1 = PageCache()
    page_metadata_1.full_url = "http://ilter.me"
    
    var dataPage = NSKeyedArchiver.archivedDataWithRootObject(page_metadata_1)
    NSUserDefaults.standardUserDefaults().setObject(dataPage, forKey: "testPageCache")
    
    
    if let reDataPage = NSUserDefaults.standardUserDefaults().objectForKey("testPageCache") as? NSData {
        let page_metadata_2 = NSKeyedUnarchiver.unarchiveObjectWithData(reDataPage) as PageCache
        print(page_metadata_2.full_url)
    }

    var device_metadata_1 = Device()
    device_metadata_1.uid = "1313131313"
    
    var dataDevice = NSKeyedArchiver.archivedDataWithRootObject(device_metadata_1)
    NSUserDefaults.standardUserDefaults().setObject(dataDevice, forKey: "testPageCache")
    
    
    if let reDataPage = NSUserDefaults.standardUserDefaults().objectForKey("testPageCache") as? NSData {
        let page_metadata_2 = NSKeyedUnarchiver.unarchiveObjectWithData(reDataPage) as Device
        print(page_metadata_2.uid)
    }
    
    
    
}

func writeToFile () {
    var site_metadata_1 = SiteMetadata()
    site_metadata_1.port = 30
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    var storePath = documentsPath.stringByAppendingString("/metadata_file")

    
    var data = NSKeyedArchiver.archivedDataWithRootObject(site_metadata_1)
    data.writeToFile(storePath, atomically: true)
    
    var ret_data = NSKeyedUnarchiver.unarchiveObjectWithFile(storePath) as SiteMetadata
    
    
    var device_1 = Device()
    device_1.uid = "13131313"
    
    var storePathDevice = documentsPath.stringByAppendingString("/device_file")
    
    
    var dataDevice = NSKeyedArchiver.archivedDataWithRootObject(device_1)
    dataDevice.writeToFile(storePathDevice, atomically: true)
    
    print(device_1.uid)
    var ret_device_data = NSKeyedUnarchiver.unarchiveObjectWithFile(storePathDevice) as Device
    
    
}

main()
writeToFile()




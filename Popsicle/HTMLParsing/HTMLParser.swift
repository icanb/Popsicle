/**@file
* @brief Swift-HTML-Parser
* @author _tid_
*/
import Foundation

func ConvXmlCharToString(str: UnsafePointer<xmlChar>) -> String! {
    if str != nil {
        return String.fromCString(UnsafeMutablePointer<CChar>(str))
    }
    return ""
}

/**
* HTMLParser
*/
class HTMLParser {
    var _doc     : htmlDocPtr = nil
    var rootNode : HTMLNode?
    
    /**
    * HTML tag
    */
    var html : HTMLNode? {
        return rootNode?.findChildTag("html")
    }
    
    /**
    * HEAD tag
    */
    var head : HTMLNode? {
        return rootNode?.findChildTag("head")
    }
    
    /**
    * BODY tag
    */
    var body : HTMLNode? {
        return rootNode?.findChildTag("body")
    }
    
    /**
    * @param[in] html  HTML文字列
    * @param[in] error エラーがあれば返します
    */
    init(html: String, inout error: NSError?) {
        if html.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            var cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
            var cfencstr : CFStringRef   = CFStringConvertEncodingToIANACharSetName(cfenc)
            
            var cur : [CChar]? = html.cStringUsingEncoding(NSUTF8StringEncoding)
            var url : String = ""
            var enc = CFStringGetCStringPtr(cfencstr, 0)
            let optionHtml : CInt = 1
            
            if var ucur = cur {
                _doc = htmlReadDoc(UnsafePointer<CUnsignedChar>(ucur), url, enc, optionHtml)
                rootNode  = HTMLNode(doc: _doc)
            } else {
                error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
            }
        } else {
            error = NSError(domain: "HTMLParserdomain", code: 1, userInfo: nil)
        }
    }
    
    deinit {
        xmlFreeDoc(_doc)
    }
}
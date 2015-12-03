//
//  HttpClient.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/21/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation

class HttpClient: NSObject {
    
    var session: NSURLSession
    
    override init () {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: http methods
    
    func httpGet(urlString: String, parameters: [String:AnyObject]!, httpHeaderFields: [String: String]!, offset: Int, completion_handler: (data: NSData!, error: String!, statusCode: String!) -> Void) -> Void {
        
        // build url with parameters
        let urlWithParams = urlString + HttpClient.escapedParameters(parameters)
        
        // build request
        let request = NSMutableURLRequest(URL: NSURL(string: urlWithParams)!)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        if (httpHeaderFields != nil) {
            for (key, value) in httpHeaderFields {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // send request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var dataWithOffset: NSData! = nil
            var errorMsg: String! = nil
            var statusCode: String! = nil
            if error != nil {
                errorMsg = error!.localizedDescription
            } else {
                statusCode = HttpClient.checkResponse(response)
                // get data for completion handler
                dataWithOffset = data!.subdataWithRange(NSMakeRange(offset, data!.length - offset)) /* subset response data! */
                //println(NSString(data: newData, encoding: NSUTF8StringEncoding)) // http GET
            }
            completion_handler(data: dataWithOffset, error: errorMsg, statusCode: statusCode)
        }
        
        task.resume()
    }
    
    
    func httpPost(urlString: String, parameters: [String:AnyObject]!, jsonBody: [String:AnyObject], httpHeaderFields: [String: String]!, offset: Int, completion_handler: (data: NSData!, error: String!) -> Void) -> Void {
        
        // build url with parameters
        let urlWithParams = urlString + HttpClient.escapedParameters(parameters)
        
        // build json body for posting data
        var jsonifyError: NSError? = nil
        let httpBody: NSData?
        do {
            httpBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch let error as NSError {
            jsonifyError = error
            httpBody = nil
        }
        if jsonifyError != nil {
            completion_handler(data: nil, error: "APP Error in jsonBody: \(jsonifyError)")
            return
        }
        
        // build request
        let request = NSMutableURLRequest(URL: NSURL(string: urlWithParams)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBody
        
        if (httpHeaderFields != nil) {
            for (key, value) in httpHeaderFields {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // send request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var dataWithOffset: NSData! = nil
            var errorMsg: String! = nil
            if error != nil {
                errorMsg = error!.localizedDescription
            } else {
                let error = HttpClient.checkResponse(response)
                if error != nil {
                    print("Error: \(error)")
                    //errorMsg = error
                }
                // get data for completion handler
                dataWithOffset = data!.subdataWithRange(NSMakeRange(offset, data!.length - offset)) /* subset response data! */
                // println(NSString(data: dataWithOffset, encoding: NSUTF8StringEncoding)) // http POST
            }
            completion_handler(data: dataWithOffset, error: errorMsg)
        }
        
        task.resume()
    }
    
    func httpPut(urlString: String, parameters: [String:AnyObject]!, jsonBody: [String:AnyObject], httpHeaderFields: [String: String]!, offset: Int, completion_handler: (data: NSData!, error: String!) -> Void) -> Void {
        
        // build url with parameters
        let urlWithParams = urlString + HttpClient.escapedParameters(parameters)
        
        // build json body for posting data
        var jsonifyError: NSError? = nil
        let httpBody: NSData?
        do {
            httpBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch let error as NSError {
            jsonifyError = error
            httpBody = nil
        }
        if jsonifyError != nil {
            completion_handler(data: nil, error: "APP Error in jsonBody: \(jsonifyError)")
            return
        }
        
        // build request
        let request = NSMutableURLRequest(URL: NSURL(string: urlWithParams)!)
        request.HTTPMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = httpBody
        
        if (httpHeaderFields != nil) {
            for (key, value) in httpHeaderFields {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // send request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var dataWithOffset: NSData! = nil
            var errorMsg: String! = nil
            if error != nil {
                errorMsg = error!.localizedDescription
            } else {
                // get data for completion handler
                dataWithOffset = data!.subdataWithRange(NSMakeRange(offset, data!.length - offset)) /* subset response data! */
                // println(NSString(data: dataWithOffset, encoding: NSUTF8StringEncoding)) // http PUT
            }
            completion_handler(data: dataWithOffset, error: errorMsg)
        }
        
        task.resume()
    }
    
    func httpDelete(urlString: String, parameters: [String:AnyObject]!, completion_handler: (data: NSData!, error: String!) -> Void) -> Void {
        
        // offset is harcoded for udacity
        let offset = 5
        
        // build url with parameters
        let urlWithParams = urlString + HttpClient.escapedParameters(parameters)
        
        // build request
        let request = NSMutableURLRequest(URL: NSURL(string: urlWithParams)!)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // prevent cross-site forgery attack
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        // send request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var dataWithOffset: NSData! = nil
            var errorMsg: String! = nil
            if error != nil {
                errorMsg = error!.localizedDescription
            } else {
                // get data for completion handler
                dataWithOffset = data!.subdataWithRange(NSMakeRange(offset, data!.length - offset)) /* subset response data! */
                //println(NSString(data: newData, encoding: NSUTF8StringEncoding)) // http DELETE
            }
            completion_handler(data: dataWithOffset, error: errorMsg)
        }
        
        task.resume()
    }
    
    // MARK: http helper functions
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]!) -> String {
        
        if parameters == nil {
            return ""
        }
        var urlVars = [String]()
        for (key, value) in parameters {
            let escapedKey = key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            /* Append it */
            urlVars += ["\(escapedKey!)=\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> Void {
        
        var parsingError: NSError? = nil
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            // print("parsedResult: \(parsedResult)")
        } catch let error as NSError {
            let msg = NSString(data: data, encoding: NSUTF8StringEncoding)
            print(msg)
            parsingError = error
            parsedResult = nil
            print("parse error: \(error)")
        }
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* return nil if OK, or diagnosis */
    class func checkResponse(response: NSURLResponse!) -> String! {
        
        if response == nil {
            return nil
        }
        let httpResponse = response as! NSHTTPURLResponse
        let statusCode = httpResponse.statusCode
        if statusCode == 200 {
            return nil
        }
        print("ERROR: statusCode = \(statusCode)")
        return "\(statusCode)"
    }
    
    // Singleton
    class func shared_instance() -> HttpClient {
        
        struct Singleton {
            static var sharedInstance = HttpClient()
        }
        return Singleton.sharedInstance
    }
}

/*
<key>NSAppTransportSecurity</key>
<dict>
<key>NSAllowsArbitraryLoads</key>
<false/>
<key>NSExceptionDomains</key>
<dict>
<key>facebook.com</key>
<dict>
<key>NSThirdPartyExceptionMinimumTLSVersion</key>
<string>TLSv1.2</string>
<key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
<false/>
<key>NSIncludesSubdomains</key>
<true/>
</dict>
</dict>
</dict>
*/
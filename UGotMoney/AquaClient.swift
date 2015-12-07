//
//  AquaClient.swift
//  UGotMoney
//
//  Created by Laurent Nicolas on 11/21/15.
//  Copyright © 2015 Laurent Nicolas. All rights reserved.
//

import Foundation

private let APPID =  "091097bb66d5a7ae7da0b0924490a8d07e9fb64bd5c2805dd760298869a7331c"
private let SECRET = "7e432962913291bad0d8c3ccef8fe0ace3d4e06fa09a5e40b610c5160936b1d2"

private let OAUTH_URL = "https://api.aqua.io/oauth/token"
private let QUERY_URL = "https://api.aqua.io/codes/beta/icd10.json"
private let CODE_URL = "https://api.aqua.io/codes/beta/icd10/"

// Interface to aqua.io services to look up or search ICD-10 codes
class AquaClient {
    
    var access_token: String! = nil
    var expiration_date: NSDate! = nil
    
    struct JSONRequestKeys {
        static let client_id = "client_id"
        static let client_secret = "client_secret"
        static let grant_type = "grant_type"
    }
    
    struct JSONRequestValues {
        static let client_credentials = "client_credentials"
    }
    
    struct JSONResponseKeys {
        static let access_token = "access_token"
        static let error = "error"
        static let error_description = "error_description"
        static let expires_in = "expires_in"
    }
    
    struct ParamsRequestKeys {
        static let access_token = "access_token"
    }
    
    // connect to aqua service and get client token
    
    func getClientToken(completion_handler: (String!) -> Void) {
        
        let urlString = OAUTH_URL
        let jsonBody = [ JSONRequestKeys.client_id: APPID,
                         JSONRequestKeys.client_secret: SECRET,
                         JSONRequestKeys.grant_type: JSONRequestValues.client_credentials
                       ]

        HttpClient.shared_instance().httpPost(urlString, parameters: nil, jsonBody: jsonBody, httpHeaderFields: nil, offset: 0) {  data, error in
            var errorMsg: String! = nil
            if let error = error {
                print(error)
                errorMsg = error
                completion_handler(errorMsg)
            } else {
                HttpClient.parseJSONWithCompletionHandler(data) { result, error in
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else {
                        let success = self.getAndSetTokenFromResult(result)
                        if (!success) {
                            let (error, errorDesc) = self.getErrorFromResult(result)
                            if error == nil && errorDesc == nil {
                                errorMsg = "ERROR: Unexpected error"
                                print(data)
                            } else {
                                errorMsg = "Error: \(error), desc: \(errorDesc)"
                            }
                        }
                    }
                    completion_handler(errorMsg)
                }
            }
        }
    }
    
    func queryICD10Codes (query: [String: String]!, completion_handler: ([[String:String]]!, String!) -> Void) {
        // a nil query bring all top level codes
        
        let urlString = QUERY_URL
        
        if access_token == nil {
            completion_handler(nil, "ERROR: not authenticated")
            return
        }
        //print(">>> access_token: \(access_token)")
        
        var params = [ParamsRequestKeys.access_token: access_token]
        if query != nil {
            for (key, value) in query {
                params[key] = value
            }
        }
        
        HttpClient.shared_instance().httpGet(urlString, parameters: params, httpHeaderFields: nil, offset: 0) { data, error, statusCode in
            
            var errorMsg: String! = nil
            if let error = error {
                print(error)
                errorMsg = error
                completion_handler(nil, errorMsg)
            } else {
                HttpClient.parseJSONWithCompletionHandler(data) { result, error in
                    
                    var results: [[String:String]]! = nil
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else {
                        results = self.getArrayFromResult(result)
                        if (results == nil) {
                            let (error, errorDesc) = self.getErrorFromResult(result)
                            if error == nil && errorDesc == nil {
                                errorMsg = "ERROR: Unexpected error"
                                print(data)
                            } else {
                                errorMsg = "Error: \(error), desc: \(errorDesc)"
                            }
                        }
                    }
                    completion_handler(results, errorMsg)
                }
            }
        }
        
    }
    
    
    
    func lookUpICD10CodesWithName(name: String, completion_handler: ([String: AnyObject]!, String!) -> Void) {
        
        let urlString = CODE_URL + name + ".json"
        lookUpICD10CodesWithURL(urlString, completion_handler: completion_handler)
    }
    
    func lookUpICD10CodesWithURL(urlString: String, completion_handler: ([String: AnyObject]!, String!) -> Void) {
        
        if access_token == nil {
            completion_handler(nil, "ERROR: not authenticated")
            return
        }
        //print(">>> access_token: \(access_token)")
        
        let params = [ParamsRequestKeys.access_token: access_token]
        
        HttpClient.shared_instance().httpGet(urlString, parameters: params, httpHeaderFields: nil, offset: 0) { data, error, statusCode in
            
            var errorMsg: String! = nil
            if let error = error {
                print(error)
                errorMsg = error
                completion_handler(nil, errorMsg)
            } else {
                HttpClient.parseJSONWithCompletionHandler(data) { result, error in
                    
                    var details: [String:AnyObject]! = nil
                    if let error = error {
                        errorMsg = error.localizedDescription
                    } else if  statusCode != nil && statusCode == "404" {
                        errorMsg = "Look up failed, invalid code"
                    } else {
                        details = self.getDictFromResult(result)
                        if (details == nil) {
                            let (error, errorDesc) = self.getErrorFromResult(result)
                            if error == nil && errorDesc == nil {
                                errorMsg = "ERROR: Unexpected error"
                                print(errorMsg + " \(__FUNCTION__)")
                                print(data)
                            } else {
                                errorMsg = "Error: \(error), desc: \(errorDesc)"
                            }
                        }
                    }
                    completion_handler(details, errorMsg)
                }
            }
        }
        
    }
    
    // MARK: extract JSON data
    
    func getAndSetTokenFromResult(result: AnyObject) -> Bool {
        
        if let access_token = result.valueForKey(JSONResponseKeys.access_token) as! String! {
            self.access_token = access_token
            if let expires_in = result.valueForKey(JSONResponseKeys.expires_in) as? Double {
                expiration_date = NSDate(timeIntervalSinceNow: expires_in - 300)
                print(expires_in)
                print(Formatting.formattedDate(expiration_date))
            }
            return true
        }
        print("ERROR: access_token key not found in \(result)")
        return false
    }
    
    func getErrorFromResult(result: AnyObject) -> (String!, String!) {
        
        var error: String! = nil
        var errorDesc: String! = nil
        if let anerror = result.valueForKey(JSONResponseKeys.error) as! String! {
            error = anerror
        }
        if let anerrorDesc = result.valueForKey(JSONResponseKeys.error_description) as! String! {
            errorDesc = anerrorDesc
        }
        return (error, errorDesc)
    }
    
    func getArrayFromResult(result: AnyObject) -> [[String:String]]! {
        
        //print(result)
        if let array = result as? [[String:String]] {
            return array
        }
        print("ERROR: cannot parse \(result)")
        return nil
    }
    
    func getDictFromResult(result: AnyObject) -> [String:AnyObject]! {
        
        //print(result)
        if let dict = result as? [String:AnyObject] {
            return dict
        }
        print("ERROR: cannot parse \(result)")
        return nil
    }


    // Singleton
    class func shared_instance() -> AquaClient {
        
        struct Singleton {
            static var sharedInstance = AquaClient()
        }
        return Singleton.sharedInstance
    }

}
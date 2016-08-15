//
//  SKRequest.swift
//  cafeGardesh
//
//  Created by saber on 7/7/16.
//  Copyright © 2016 saber. All rights reserved.
//

import UIKit

public class SKRequest: NSObject {
    
    var completionHandler:(AnyObject?,NSURLResponse?,String?)->Void = {
        (data: AnyObject?, res : NSURLResponse? ,error : String?) -> Void in
    }
    var task : NSURLSessionDataTask!
    
    
    init( Url : String! , Method : RequestMode = .POST  , timeOut : NSTimeInterval = 5 ,parameters : NSDictionary? = nil, headers : NSDictionary? = nil, onCompletion: ((data : AnyObject? , res : NSURLResponse? ,error : String?) -> Void)?){
        completionHandler = onCompletion!
        var urlRequest = Url
        
        
        
        super.init()
        if parameters != nil {
            if  Method == .GET {
                urlRequest = urlRequest + "?"
                let itemsArray = parameters!.allKeys as! [String]
                for item in itemsArray {
                    urlRequest = urlRequest + item + "=" + (parameters![item] as! String)
                    if itemsArray.indexOf(item) != (itemsArray.count - 1) {
                        urlRequest = urlRequest + "&"
                    }
                }
            }
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: urlRequest.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)!)
        request.timeoutInterval = timeOut
        request.HTTPMethod = Method.rawValue
        if headers != nil {
            for item in headers! {
                request.setValue(item.value as? String, forHTTPHeaderField: (item.key as? String)!)
            }
        }
        
        
        
        
        task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.completionHandler(nil, response, "Request failed with error: \(error!.userInfo["NSLocalizedDescription"]!)")
                    
                    
                    
                    
                })
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                //                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                dispatch_async(dispatch_get_main_queue(), {
                    self.completionHandler(nil, response, "statusCode should be 200, but is \(httpStatus.statusCode)")
                    
                    
                    
                })
                return
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.completionHandler(self.convertDataToJson(data!), response!, nil)
                
            })
            
        }
        
        task.resume()
        
        
    }
    private func convertDataToJson(data : NSData?) -> AnyObject? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data!, options: [])
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    
    
    
    internal enum RequestMode : String{
        case POST = "POST"
        case GET = "GET"
        case PATCH = "PATCH"
        case DELETE = "DELETE"
    }
}



//
//  NetworkManager.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/22/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

/*
 This is the manager for all network access. Use this to talk to the web.
 */

class NetworkManager {
    
    static var defaultURLSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    //--- Class Vars for Methods ---//
    
    private static var dataTaskCounter: Int = 0 {
        didSet {
            if dataTaskCounter < 0 {
                dataTaskCounter = 0
            }
            if dataTaskCounter > 0 {
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
            }
        }
    }
    
    //--- Methods ---//
    
    static func loadData(url: NSURL, urlSession: NSURLSession?) {
        urlSession?.dataTaskWithURL(url).resume()
    }
    
    static func loadData(url: NSURL, urlSession: NSURLSession?, completion: ((data: NSData) -> Void)) {
        
        print(url)
        
        let session = urlSession ?? defaultURLSession
        
        dataTaskCounter += 1
        
        let dataTask = session.dataTaskWithURL(url) {
            data, response, error in
            
            //network indicator
            dataTaskCounter -= 1
            
            if let error = error {
                print(error.localizedDescription)
            } else if let HTTPResponse = response as? NSHTTPURLResponse {
                if HTTPResponse.statusCode == 200 {
                    guard let data = data else { print("loadData() for url:\(url) error. Data is nil"); return }
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(data: data)
                    }
                } else {
                    print("HTTP Error (\(HTTPResponse.statusCode))")
                }
            }
        }
        dataTask.resume()
    }
}

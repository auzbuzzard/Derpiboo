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
    
    static var defaultURLSession = URLSession(configuration: URLSessionConfiguration.default)
    
    //--- Class Vars for Methods ---//
    
    fileprivate static var dataTaskCounter: Int = 0 {
        didSet {
            if dataTaskCounter < 0 {
                dataTaskCounter = 0
            }
            if dataTaskCounter > 0 {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
            } else {
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }
    
    //--- Methods ---//
    
    static func loadData(_ url: URL, urlSession: URLSession?) {
        urlSession?.dataTask(with: url).resume()
    }
    
    static func loadData(_ url: URL, urlSession: URLSession?, completion: @escaping ((_ data: Data) -> Void)) {
        
        //print(url)
        
        let session = urlSession ?? defaultURLSession
        
        dataTaskCounter += 1
        
        let dataTask = session.dataTask(with: url, completionHandler: {
            data, response, error in
            
            //network indicator
            dataTaskCounter -= 1
            
            if let error = error {
                print(error.localizedDescription)
            } else if let HTTPResponse = response as? HTTPURLResponse {
                if HTTPResponse.statusCode == 200 {
                    guard let data = data else { print("loadData() for url:\(url) error. Data is nil"); return }
                    DispatchQueue.main.async {
                        completion(data)
                    }
                } else {
                    print("HTTP Error (\(HTTPResponse.statusCode))")
                }
            }
        }) 
        dataTask.resume()
    }
}

//
//  Utils.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/11/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class Utils {
    
    //--- Default Images ---//
    
    struct Images_URL {
        static let no_avatar = NSURL(string: "https://derpicdn.net/assets/no_avatar-1f16e058f8de3098c829dbfded69eb028fc02f52cccb886edc659e93011545fe.svg")
    }
    
//    static func getImages(url: NSURL, completion: (image: UIImage?, error: ErrorType?) -> Void)) {
//        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
//        
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        
//        let dataTask = urlSession.dataTaskWithURL(url) {
//            data, response, error in
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            }
//            
//            if let error = error {
//                print(error.localizedDescription)
//            } else if let HTTPResponse = response as? NSHTTPURLResponse {
//                if HTTPResponse.statusCode == 200 {
//                    guard let data = data else { return completion(image: nil, error: error) }
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
//                        guard let image = UIImage(data: data) else { print("data to image error"); return completion(image: self, error: error) }
//                        dispatch_async(dispatch_get_main_queue()) {
//                            completion(image: self, error: nil)
//                        }
//                    }
//                    
//                } else {
//                    print("HTTP Error (\(HTTPResponse.statusCode)")
//                }
//            }
//        }
//        dataTask.resume()
//
//    }
    
}

extension String {
    func toURL() -> NSURL? {
        //print(self)
        guard let url = NSURL(string: self) else { print("URL Error. Cannot create NSURL from: \"\(self)\""); return nil }
        return url
    }
}









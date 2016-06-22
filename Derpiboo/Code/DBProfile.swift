//
//  DBProfile.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/21/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

struct DBProfile {
    let id: Int
    let name: String
    let slug: String
    let role: String
    let description: String
    let avatar_url: String
    let created_at: String
    let comment_count: Int
    let uploads_count: Int
    let post_count: Int
    let topic_count: Int
    
    let awards: [DBProfileAwards]
    
    var avatar: UIImage?
    
    mutating func downloadAvatar(urlSession: NSURLSession, completion: (image: DBProfile, error: ErrorType?) -> Void) {
        guard let url = NSURL(string: "https:\(avatar_url)") else { print("download avatar url error, url: \(avatar_url)"); return }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let dataTask = urlSession.dataTaskWithURL(url) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let HTTPResponse = response as? NSHTTPURLResponse {
                if HTTPResponse.statusCode == 200 {
                    guard let data = data else { return completion(image: self, error: error) }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                        guard let image = UIImage(data: data) else { print("data to image error"); return completion(image: self, error: error) }
                        self.avatar = image
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(image: self, error: nil)
                        }
                    }
                    
                } else {
                    print("HTTP Error (\(HTTPResponse.statusCode)")
                }
            }
        }
        dataTask.resume()
    }
    
}

struct DBProfileAwards {
    let image_url: String
    let title: String
    let id: Int
    let awarded_on: String
}









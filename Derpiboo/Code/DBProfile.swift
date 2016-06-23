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
    
    mutating func downloadAvatar(urlSession: NSURLSession?, completion: ((profile: DBProfile?) -> Void)?) {
        
        guard let url = "https:\(avatar_url)".toURL() else { print("download avatar url error, url: \(avatar_url)"); return }
        
        NetworkManager.loadData(url, urlSession: urlSession, completion: { data in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                
                guard let image = UIImage(data: data) else { print("data to image error");completion?(profile: nil) ; return }
                self.avatar = image
                dispatch_async(dispatch_get_main_queue()) {
                    completion?(profile: self)
                }
            }
        })
    }
    
}

struct DBProfileAwards {
    let image_url: String
    let title: String
    let id: Int
    let awarded_on: String
}









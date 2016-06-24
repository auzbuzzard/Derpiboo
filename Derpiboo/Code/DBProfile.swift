//
//  DBProfile.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/21/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class DBProfile {
    let id: Int
    let name: String
    let slug: String
    let role: String
    let description: String?
    let avatar_url: String?
    let created_at: String
    let comment_count: Int
    let uploads_count: Int
    let post_count: Int
    let topic_count: Int
    
    let awards: [DBProfileAwards]
    
    var avatar: UIImage?
    
    init(id: Int, name: String, slug: String, role: String, description: String?, avatar_url: String?, created_at: String, comment_count: Int, uploads_count: Int, post_count: Int, topic_count: Int, awards: [DBProfileAwards], avatar: UIImage?) {
        self.id = id
        self.name = name
        self.slug = slug
        self.role = role
        self.description = description
        self.avatar_url = avatar_url
        self.created_at = created_at
        self.comment_count = comment_count
        self.uploads_count = uploads_count
        self.post_count = post_count
        self.topic_count = topic_count
        self.awards = awards
        self.avatar = avatar
    }
    
    func downloadAvatar(urlSession: NSURLSession?, completion: ((profile: DBProfile?) -> Void)?) {
        guard let avatar_url = avatar_url else { return }
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









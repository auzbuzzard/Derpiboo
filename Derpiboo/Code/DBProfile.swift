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
    
    func downloadAvatar(_ urlSession: URLSession?, completion: ((_ profile: DBProfile?) -> Void)?) {
        guard let avatar_url = avatar_url else { return }
        guard let url = "https:\(avatar_url)".toURL() else { print("download avatar url error, url: \(avatar_url)"); return }
        
        NetworkManager.loadData(url, urlSession: urlSession, completion: { data in
            
            DispatchQueue.global(qos: .utility).async {
                
                guard let image = UIImage(data: data) else { print("data to image error");completion?(nil) ; return }
                self.avatar = image
                DispatchQueue.main.async {
                    completion?(self)
                }
            }
        })
    }
    
    func downloadAwardImage(_ award: DBProfileAwards, urlSession: URLSession?, completion: ((_ image: UIImage?) -> Void)?) {
        guard let url = "https:\(award.image_url)".toURL() else { print("downloadAwardImage() url error, url: \(award.image_url)"); return }
        
        NetworkManager.loadData(url, urlSession: urlSession, completion: { data in
            
            DispatchQueue.global(qos: .utility).async {
                
                guard let image = UIImage(data: data) else { print("data to image error for award image"); completion?(nil); return }
                DispatchQueue.main.async {
                    award.image = image
                    completion?(image)
                }
                
            }
            
        })
    }
    
}

class DBProfileAwards {
    let image_url: String
    let title: String
    let id: Int
    let awarded_on: String
    
    init(image_url: String, title: String, id: Int, awarded_on: String) {
        self.image_url = image_url
        self.title = title
        self.id = id
        self.awarded_on = awarded_on
    }
    
    var image: UIImage?
}









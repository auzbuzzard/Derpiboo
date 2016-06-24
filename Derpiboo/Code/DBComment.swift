//
//  DBComments.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/23/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class DBComment {
    let id: Int
    let body: String
    let author: String
    let image_id: Int
    let posted_at: String
    let deleted: Bool
    
    init(id: Int, body: String, author: String, image_id: Int, posted_at: String, deleted: Bool, authorProfile: DBProfile?) {
        self.id = id
        self.body = body
        self.author = author
        self.image_id = image_id
        self.posted_at = posted_at
        self.deleted = deleted
        self.authorProfile = authorProfile
    }
    
    var authorProfile: DBProfile?
    
    func downloadProfile(clientProfile: DBClientProfile?, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, completion: ((profile: DBProfile?) -> Void)?) {
        
        let client = clientProfile ?? DBClientProfile()
        
        client.loadProfile(author, preloadAvatar: preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: { profile in
            self.authorProfile = profile
            completion?(profile: profile)
        })
        
    }
}

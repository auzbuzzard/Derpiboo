//
//  DBData.swift
//  Derpiboo
//
//  Created by Austin Chau on 10/4/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation

protocol DBData {
    
}

class DBImage {
    //Data
    let id: String
    //let id_number: Int //doesn't exist anymore after jun 28
    
    var created_at: String?
    var updated_at: String?
    
    var duplicate_reports: [AnyObject]?
    
    var first_seen_at: String?
    
    var file_name: String?
    var description: String?
    var uploader: String?
    
    var image: String?
    
    var score: Int?
    var upvotes: Int?
    var downvotes: Int?
    var faves: Int?
    
    var comment_count: Int?
    
    var tags: String?
    var tag_ids: [Int]?
    
    var width: Int?
    var height: Int?
    var aspect_ratio: Double?
    
    var original_format: String?
    var mime_type: String?
    
    var sha512_hash: String?
    var orig_sha512_hash: String?
    var source_url: String?
    
    //representations
    var thumb_tiny: String?
    var thumb_small: String?
    var thumb: String?
    var small: String?
    var medium: String?
    var large: String?
    var tall: String?
    var full: String?
    
    var is_rendered: Bool?
    var is_optimized: Bool?
    
    init(id: String) {
        self.id = id
    }
}

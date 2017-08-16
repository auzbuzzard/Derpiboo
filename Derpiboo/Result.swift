//
//  Result.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class Result {
    
}

class ListResult: Result {
    
    lazy var results = [ImageResult]()
    
    var page: Int = 1
    
    func add(results newResults: [ImageResult]) {
        results.append(contentsOf: newResults)
        page += 1
    }
    
}

class ImageResult: Result {
    
    var id: String { get { return metadata.id } }
    
    var metadata: Metadata {
        didSet {
            _ = getImage(ofSize: .large, callback: { _ in })
        }
    }
    
    struct Metadata {
        let id: String
        
        let created_at: String
        let updated_at: String
        
        let duplicate_reports: [AnyObject]
        
        let first_seen_at: String
        
        let file_name: String
        let description: String
        let uploader: String
        
        let image: String
        
        let score: Int
        let upvotes: Int
        let downvotes: Int
        let faves: Int
        
        let comment_count: Int
        
        let tags: String
        let tag_ids: [Int]
        
        let width: Int
        let height: Int
        let aspect_ratio: Double
        
        let original_format: String
        let mime_type: String
        
        let sha512_hash: String
        let orig_sha512_hash: String
        let sourse_url: String
        
        let representations: Representations
        
        struct Representations {
            let thumb_tiny: String
            let thumb_small: String
            let thumb: String
            let small: String
            let medium: String
            let large: String
            let tall: String
            let full: String
        }
        
        let is_rendered: Bool
        let is_optimized: Bool
        
        enum SizeType: String {
            case thumb, large, full
        }
    }
    
    func hasImageInCache(ofSize size: Metadata.SizeType) -> Bool {
        if let _ = try? Cache.shared.getImage(size: size, id: self.id) {
            return true
        } else {
            return false
        }
    }
    
    func getImage(ofSize size: Metadata.SizeType, callback: ((_ image: UIImage?, _ id: String, ImageResultError?) -> Void)?) -> UIImage? {
        if let image = try? Cache.shared.getImage(size: size, id: self.id) {
            callback?(image, self.id, nil)
            return image
        } else {
            if let callback = callback {
                var url = ""
                switch size {
                case .thumb: url = "https:" + metadata.representations.thumb
                case .large: url = "https:" + metadata.representations.large
                case .full: url = "https:" + metadata.image
                }
                do {
                    try Network.fetch(url: url, params: nil, completion: { data in
                        if let image = UIImage(data: data) {
                            do {
                                try Cache.shared.setImage(size: size, image: image, forID: self.id)
                                callback(image, self.id, nil)
                            } catch {
                                print("store error")
                            }
                        } else {
                            callback(nil, self.id, ImageResultError.ImageDownloadError(id: self.id, url: url))
                        }
                    })
                } catch {
                    print("getImage error")
                }
            }
            return nil
        }
    }
    
    func setImage(ofSize size: Metadata.SizeType, image: UIImage) {
        
    }
    
    init(metadata: Metadata) {
        self.metadata = metadata
    }
    
    enum ImageResultError: Error {
        case ImageDownloadError(id: String, url: String)
        case ImageNotInCache(id: Int)
    }
}

class UserResult: Result {
    
    var id: Int { get { return metadata.id } }
    
    var metadata: Metadata
    
    struct Metadata {
        let name: String
        let id: Int
        let level: Int
        let avatar_id: Int?
    }
    
    init(metadata: Metadata) {
        self.metadata = metadata
    }
    
}

class FilterResult: Result {
    
    var id: Int { get { return metadata.id } }
    var name: String { get { return metadata.name } }
    
    var metadata: Metadata
    
    struct Metadata {
        let id: Int
        let name: String
        let description: String
        let hidden_tag_ids: [Int]
        let spoilered_tag_ids: [Int]
        let spoilered_tags: String
        let hidden_tags: String
        let hidden_complex: String
        let spoilered_complex: String
        let isPublic: Bool
        let system: Bool
        let user_count: Int
    }
    init(metadata: Metadata) {
        self.metadata = metadata
    }
}

class FilterListResult: Result {
    lazy var system_filters = [FilterResult]()
    lazy var user_filters = [FilterResult]()
    lazy var search_filters = [FilterResult]()
}




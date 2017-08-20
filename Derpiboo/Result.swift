//
//  Result.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit

protocol Result {
    
}

protocol ResultListable: Result {
    associatedtype Item: ResultItem
    var results: [Item] { get set }
}
extension ResultListable {
    mutating func add(_ result: [Item]) {
        results.append(contentsOf: result)
    }
    mutating func add(_ result: Self) {
        add(result.results)
    }
}

protocol ResultItem: Result {
    associatedtype Metadata: ResultItemMetadata
    var id: String { get }
    var metadata: Metadata { get }
}

protocol ResultItemMetadata { }


// Mark: - Actual Classes

struct ListResult: ResultListable {
    typealias ResultType = ImageResult
    
    var results: [ResultType]
    private(set) var currentPage = 0
    var tags: [String]?
    var tagsAsString: String? { return tags?.joined(separator: " ") }
    
    init() {
        results = [ResultType]()
    }
    init(result: [ResultType]) {
        self.init()
        add(result)
    }
    
    mutating func add(_ result: [ResultType]) {
        results.append(contentsOf: result)
        currentPage += 1
    }
    mutating func add(_ result: ListResult) {
        add(result.results)
    }
}

struct ImageResult: ResultItem, UsingImageCache {
    var id: String { return metadata.id }
    
    private(set) var metadata: Metadata
    
    struct Metadata: ResultItemMetadata {
        let id: String
        
        let created_at: String
        let updated_at: String
        
        let duplicate_reports: [AnyObject]
        
        let first_seen_at: String
        
        let file_name: String
        let description: String
        
        let uploader_id: String
        let uploader: String
        
        let image: String
        
        let score: Int
        let upvotes: Int
        let downvotes: Int
        let faves: Int
        
        let comment_count: Int
        
        let tags: String
        let tag_ids: [String]
        
        //let rating: Ratings
        
        let width: Int
        let height: Int
        let aspect_ratio: Double
        
        let original_format: String
        let mime_type: String
        var original_format_enum: File_Ext? {
            return File_Ext(rawValue: original_format) ?? nil
        }
        
        let sha512_hash: String
        let orig_sha512_hash: String?
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
        
        enum ImageSize: String {
            case thumb, large, full
        }
        enum File_Ext: String {
            case jpg = "jpg", png = "png", gif = "gif", swf = "swf", webm = "webm"
        }
        enum Ratings: String {
            case safe, suggestive, explicit = "26707"
        }
    }
    
    func imageData(forSize size: Metadata.ImageSize) -> Promise<Data> {
        return imageDataFromCache(size: size)
            .recover { error -> Promise<Data> in
                if case ImageCache.CacheError.noImageInStore(_) = error {
                    return self.downloadImageData(forSize: size)
                } else {
                    throw error
                }
        }
    }
    
    func imageDataFromCache(size: Metadata.ImageSize) -> Promise<Data> {
        return imageCache.getImageData(for: self.id, size: size)
    }
    
    func downloadImageData(forSize size: Metadata.ImageSize) -> Promise<Data> {
        let url: String = {
            switch size {
            case .thumb: return "https:" + metadata.representations.thumb
            case .large: return "https:" + metadata.representations.large
            case .full: return "https:" + metadata.representations.full
            }
        }()
        
        return Network.get(url: url)
            .then { data -> Promise<Data> in
                _ = self.imageCache.setImageData(data, id: self.id, size: size)
                return Promise(value: data)
        }
    }
    
    enum ImageResultError: Error {
        case downloadFailed(id: String, url: String)
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

struct TagResult: ResultItem {
    var id: String { return metadata.id }
    
    private(set) var metadata: Metadata
    
    struct Metadata: ResultItemMetadata {
        let id: String
        let name: String
        let slug: String
        let description: String
        let short_description: String
        let images: Int
        let spoiler_image_uri: String?
        let aliased_to: String?
        let aliased_to_id: String?
        let namespace: String?
        let name_in_namespace: String?
        let implied_tags: String?
        let implied_tag_ids: [Int]?
        let category: String?
    }
}








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
protocol ResultItemInt: Result {
    associatedtype Metadata: ResultItemMetadata
    var id: Int { get }
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



class UserResult: Result {
    
    var id: Int { get { return metadata.id } }
    
    var metadata: Metadata
    
    struct Metadata {
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
        
        let links: [Any]
        let awards: [MetadataAwards]
    }
    
    struct MetadataAwards {
        let image_url: String
        let title: String
        let id: Int
        let label: String
        let awarded_on: String
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
    
    static func getTag(for id: String) -> Promise<TagResult> {
        return Cache.tag.getTag(for: id).recover { error -> Promise<TagResult> in
            if case TagCache.CacheError.noTagInStore(_) = error {
                return TagRequester().downloadTag(for: id)
            } else {
                return Promise<TagResult>(error: error)
            }
        }
    }
}

struct CommentResult: ResultItemInt {
    var id: Int { return metadata.id }
    private(set) var metadata: Metadata
    
    struct Metadata: ResultItemMetadata {
        let id: Int
        let body: String
        let author: String
        let image_id: Int
        let posted_at: String
        let deleted: Bool
    }
}






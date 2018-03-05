//
//  Result.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit

protocol ModelResult {
    
}

protocol ResultListable: ModelResult {
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

protocol ResultItem: ModelResult {
    associatedtype Metadata: ResultItemMetadata
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



struct UserResult: ResultItem {
    
    var id: Int { return metadata.id }
    
    var metadata: Metadata
    
    struct Metadata: ResultItemMetadata {
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
    
    static func getUser(by slug: String) -> Promise<UserResult> {
        return Cache.user.getUser(for: slug)
        .recover { error -> Promise<UserResult> in
            switch error {
            case UserCache.CacheError.noUserInStore(_), UserCache.CacheError.slugNotConvertible(_):
                return UserRequester().getUser(bySlug: slug)
            default: throw error
            }
        }
    }
    
    enum UserResultError: Error {
        case noUserFound(slug: String)
    }
    
}

struct FilterListResult: ModelResult {
    let system_filters: [FilterResult]
    let user_filters: [FilterResult]?
    let search_filters: [FilterResult]
}

struct FilterResult: ResultItem {
    
    var id: Int { get { return metadata.id } }
    var name: String { get { return metadata.name } }
    
    var metadata: Metadata
    
    struct Metadata: ResultItemMetadata {
        let id: Int
        let name: String
        let description: String
        let hidden_tag_ids: [Int]
        let spoilered_tag_ids: [Int]
        let spoilered_tags: String
        let hidden_tags: String
        let hidden_complex: String
        let spoilered_complex: String
        let `public`: Bool
        let system: Bool
        let user_count: Int
        let user_id: Int?
    }
    init(metadata: Metadata) {
        self.metadata = metadata
    }
}

struct TagResult: ResultItem {
    var id: Int { return metadata.id }
    
    private(set) var metadata: Metadata
    
    struct Metadata: ResultItemMetadata {
        let id: Int
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
    
    static func getTag(for id: Int) -> Promise<TagResult> {
        return Cache.tag.getTag(for: id).recover { error -> Promise<TagResult> in
            if case TagCache.CacheError.noTagInStore(_) = error {
                return TagRequester().downloadTag(for: id)
            } else {
                return Promise<TagResult>(error: error)
            }
        }
    }
}

struct CommentResult: ResultItem {
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






















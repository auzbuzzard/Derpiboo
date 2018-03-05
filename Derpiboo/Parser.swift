//
//  Parser.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: - Protocols

protocol Parser {
    associatedtype ParseResult: ModelResult
    static func parse(data: Data) -> Promise<ParseResult>
}

protocol ParserForList {
    associatedtype ParseResult: ModelResult
    static func parse(data: Data) -> Promise<[ParseResult]>
}

protocol ParserForItem {
    associatedtype Result: ResultItem
    static func parse(dictionary item: NSDictionary) -> Promise<Result>
}

extension ParserForItem {
    static func parse(data: Data) -> Promise<Result> {
        return Promise<NSDictionary> { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary { fulfill(json) }
                else { reject(ParserError.CannotCastJsonIntoNSDictionary(data: data)) }
            } catch {
                reject(error)
            }
        }.then { json -> Promise<Result> in
            return parse(dictionary: json)
        }
    }
}

enum ParserError: Error {
    case JsonDataCorrupted(data: Data)
    case CannotCastJsonIntoNSDictionary(data: Data)
    case parserGuardFailed(id: String, variable: String)
}

// MARK: - Implementation

struct UserParser: ParserForItem {
    static func parse(dictionary item: NSDictionary) -> Promise<UserResult> {
        guard let id = item["id"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "0", variable: "id")) }
        guard let name = item["name"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "name")) }
        guard let slug = item["slug"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "slug")) }
        guard let role = item["role"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "role")) }
        let description = item["description"] as? String
        let avatar_url = item["avatar_url"] as? String
        guard let created_at = item["created_at"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "created_at")) }
        guard let comment_count = item["comment_count"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "comment_count")) }
        guard let uploads_count = item["uploads_count"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "uploads_count")) }
        guard let post_count = item["post_count"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "post_count")) }
        guard let topic_count = item["topic_count"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "topic_count")) }
        
        // TODO: - Implement links
        let links: [Any] = []
        
        guard let awards: [UserResult.MetadataAwards] = {
            guard let json = item["awards"] as? Array<NSDictionary> else { return nil }
            
            return json.flatMap { awardItem in
                guard let image_url = awardItem["image_url"] as? String else { print(ParserError.parserGuardFailed(id: "\(id)", variable: "awards_image_url")); return nil }
                guard let title = awardItem["title"] as? String else { print(ParserError.parserGuardFailed(id: "\(id)", variable: "awards_title")); return nil }
                guard let award_id = awardItem["id"] as? Int else { print(ParserError.parserGuardFailed(id: "\(id)", variable: "awards_id")); return nil }
                guard let label = awardItem["label"] as? String else { print(ParserError.parserGuardFailed(id: "\(id)", variable: "awards_label")); return nil }
                guard let awarded_on = awardItem["awarded_on"] as? String else { print(ParserError.parserGuardFailed(id: "\(id)", variable: "awards_awarded_on")); return nil }
                
                return UserResult.MetadataAwards(image_url: image_url, title: title, id: award_id, label: label, awarded_on: awarded_on)
            }
        }() else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "awards")) }
        
        let metadata = UserResult.Metadata(id: id, name: name, slug: slug, role: role, description: description, avatar_url: avatar_url, created_at: created_at, comment_count: comment_count, uploads_count: uploads_count, post_count: post_count, topic_count: topic_count, links: links, awards: awards)
        
        return Promise(value: UserResult(metadata: metadata))
    }
}

class TagParser: Parser, ParserForItem {
    static func parse(data: Data) -> Promise<TagResult> {
        return Promise<NSDictionary> { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary,
                    let tag = json["tag"] as? NSDictionary { fulfill(tag) }
                else { reject(ParserError.CannotCastJsonIntoNSDictionary(data: data)) }
            } catch {
                reject(error)
            }
        }.then { json in return parse(dictionary: json) }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<TagResult> {
        let id = item["id"] as? Int ?? 0
        let name = item["name"] as? String ?? ""
        let slug = item["slug"] as? String ?? ""
        let description = item["description"] as? String ?? ""
        let short_description = item["short_description"] as? String ?? ""
        let images = item["images"] as? Int ?? 0
        let spoiler_image_uri = item["spoiler_image_uri"] as? String
        let aliased_to = item["aliased_to"] as? String
        let aliased_to_id = item["aliased_to_id"] as? String
        let namespace = item["namespace"] as? String
        let name_in_namespace = item["name_in_namespace"] as? String
        let implied_tags = item["implied_tags"] as? String
        let implied_tag_ids = item["implied_tag_ids"] as? [Int]
        let category = item["category"] as? String
        
        let metadata = TagResult.Metadata(id: id, name: name, slug: slug, description: description, short_description: short_description, images: images, spoiler_image_uri: spoiler_image_uri, aliased_to: aliased_to, aliased_to_id: aliased_to_id, namespace: namespace, name_in_namespace: name_in_namespace, implied_tags: implied_tags, implied_tag_ids: implied_tag_ids, category: category)
        
        return Promise(value: TagResult(metadata: metadata))
    }
}

struct CommentParser: ParserForList {
    static func parse(data: Data) -> Promise<[CommentResult]> {
        return Promise<Array<NSDictionary>> { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary,
                    let comments = json["comments"] as? Array<NSDictionary> { fulfill(comments) }
                else { reject(ParserError.CannotCastJsonIntoNSDictionary(data: data)) }
            } catch {
                reject(error)
            }
        }.then(on: .global(qos: .userInitiated)) { comments in
            return when(resolved: comments.map{ return parse(dictionary: $0) })
        }.then(on: .global(qos: .userInitiated)) { results in
            return results.flatMap {
                if case let .fulfilled(value) = $0 { return value } else { return nil }
            }
        }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<CommentResult> {
        guard let id = item["id"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "0", variable: "id")) }
        guard let body = item["body"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "body")) }
        guard let author = item["author"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "author")) }
        guard let image_id = item["image_id"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "image_id")) }
        guard let posted_at = item["posted_at"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "posted_at")) }
        guard let deleted = item["deleted"] as? Bool else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "deleted")) }
        
        let metadata = CommentResult.Metadata(id: id, body: body, author: author, image_id: image_id, posted_at: posted_at, deleted: deleted)
        
        return Promise(value: CommentResult(metadata: metadata))
    }
}

struct FilterListParser: Parser {
    
    static func parse(data: Data) -> Promise<FilterListResult> {
        return Promise<NSDictionary> { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary { fulfill(json) }
                else { reject(ParserError.CannotCastJsonIntoNSDictionary(data: data)) }
            } catch {
                reject(error)
            }
        }.then(on: .global(qos: .userInitiated)) { json -> Promise<[Result<[Result<FilterResult>]>]> in
            guard let system_filters_json = json["system_filters"] as? Array<NSDictionary> else { return Promise(error: ParserError.parserGuardFailed(id: "FilterListParser", variable: "system_filters")) }
            guard let search_filters_json = json["search_filters"] as? Array<NSDictionary> else { return Promise(error: ParserError.parserGuardFailed(id: "FilterListParser", variable: "search_filters")) }
            let user_filters_json = json["user_filters"] as? Array<NSDictionary>
            
            let system_filters = when(resolved: system_filters_json.map { return FilterParser.parse(dictionary: $0) })
            let search_filters = when(resolved: search_filters_json.map { return FilterParser.parse(dictionary: $0) })
            let user_filters: Promise<[Result<FilterResult>]>? = {
                if let user_filters_json = user_filters_json {
                    return when(resolved: user_filters_json.map { return FilterParser.parse(dictionary: $0) } )
                } else { return nil }
            }()
            if let user_filters = user_filters { return when(resolved: system_filters, search_filters, user_filters) }
            else { return when(resolved: system_filters, search_filters) }
            
        }.then(on: .global(qos: .userInitiated)) { results in
            var system_filters = [FilterResult]()
            var search_filters = [FilterResult]()
            var user_filters = [FilterResult]()
            
            for case let (index, .fulfilled(value)) in results.enumerated() {
                let arr: [FilterResult] = value.flatMap { if case let .fulfilled(value) = $0 { return value } else { return nil } }
                switch index {
                case 0: system_filters = arr
                case 1: search_filters = arr
                case 2: user_filters = arr
                default: break
                }
            }
            
            return Promise(value: FilterListResult(system_filters: system_filters, user_filters: user_filters, search_filters: search_filters))
            
        }.catch { error in print(error) }
    }
}

struct FilterParser: ParserForItem {
    static func parse(dictionary item: NSDictionary) -> Promise<FilterResult> {
        let id = item["id"] as? Int ?? 0
        let name = item["name"] as? String ?? ""
        let description = item["description"] as? String ?? ""
        let hidden_tag_ids = item["hidden_tag_ids"] as? [Int] ?? [Int]()
        let spoilered_tag_ids = item["spoilered_tag_ids"] as? [Int] ?? [Int]()
        let spoilered_tags = item["spoilered_tags"] as? String ?? ""
        let hidden_tags = item["hidden_tags"] as? String ?? ""
        let hidden_complex = item["hidden_complex"] as? String ?? ""
        let spoilered_complex = item["spoilered_complex"] as? String ?? ""
        let `public` = item["public"] as? Bool ?? false
        let system = item["system"] as? Bool ?? false
        let user_count = item["user_count"] as? Int ?? 0
        let user_id = item["user_id"] as? Int
        
        let metadata = FilterResult.Metadata(id: id, name: name, description: description, hidden_tag_ids: hidden_tag_ids, spoilered_tag_ids: spoilered_tag_ids, spoilered_tags: spoilered_tags, hidden_tags: hidden_tags, hidden_complex: hidden_complex, spoilered_complex: spoilered_complex, public: `public`, system: system, user_count: user_count, user_id: user_id)
        
        return Promise { fulfill, _ in
            fulfill(FilterResult(metadata: metadata))
        }
    }
}






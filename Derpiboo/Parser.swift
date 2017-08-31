//
//  Parser.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

protocol Parser {
    associatedtype ParseResult: Result
    static func parse(data: Data) -> Promise<ParseResult>
}

protocol ParserForList {
    associatedtype ParseResult: Result
    static func parse(data: Data, as listType: ListRequester.ListType) -> Promise<ParseResult>
}

protocol ParserForItem {
    associatedtype Result: ResultItem
    static func parse(dictionary item: NSDictionary) -> Promise<Result>
}

enum ParserError: Error {
    case JsonDataCorrupted(data: Data)
    case CannotCastJsonIntoNSDictionary(data: Data)
}

class ListParser: ParserForList {
    static func parse(data: Data, as listType: ListRequester.ListType) -> Promise<ListResult> {
        return Promise { fulfill, reject in
            do {
                let key: String = {
                    switch listType {
                    case .images, .lists: return "images"
                    case .search: return "search"
                    }
                }()
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary, let items = json[key] as? Array<NSDictionary> else { reject(ParserError.CannotCastJsonIntoNSDictionary(data: data)); return }
                
                var results = [ImageResult]()
                
                for item in items {
                    ImageParser.parse(dictionary: item).then { result -> Void in
                        results.append(result)
                        }.catch { error -> Void in
                            
                    }
                }
                fulfill(ListResult(result: results))
            } catch {
                reject(error)
            }
        }
    }
}

class ImageParser: Parser, ParserForItem {
    
    static func parse(data: Data) -> Promise<ImageResult> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    parse(dictionary: json).then { result -> Void in
                        fulfill(result)
                        }.catch { error in
                            reject(error)
                    }
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            }
        }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<ImageResult> {
        let id = item["id"] as? String ?? ""
        
        let created_at = item["created_at"] as? String ?? ""
        let updated_at = item["updated_at"] as? String ?? ""
        
        let duplicate_reports = item["duplicate_reports"] as? [AnyObject] ?? [AnyObject]()
        
        let first_seen_at = item["first_seen_at"] as? String ?? ""
        
        let file_name = item["file_name"] as? String ?? ""
        let description = item["description"] as? String ?? ""
        let uploader = item["uploader"] as? String ?? ""
        let uploader_id = item["uploader_id"] as? String ?? ""
        
        let image = item["image"] as? String ?? ""
        
        let score = item["score"] as? Int ?? 0
        let upvotes = item["upvotes"] as? Int ?? 0
        let downvotes = item["downvotes"] as? Int ?? 0
        let faves = item["faves"] as? Int ?? 0
        
        let comment_count = item["comment_count"] as? Int ?? 0
        
        let tags = item["tags"] as? String ?? ""
        let tag_ids = item["tag_ids"] as? [String] ?? [String]()
        
        let width = item["width"] as? Int ?? 1
        let height = item["height"] as? Int ?? 1
        let aspect_ratio = item["aspect_ratio"] as? Double ?? (Double)(width/height)
        
        let original_format = item["original_format"] as? String ?? ""
        let mime_type = item["mime_type"] as? String ?? ""
        
        let sha512_hash = item["sha512_hash"] as? String ?? ""
        let orig_sha512_hash = item["orig_sha512_hash"] as? String ?? ""
        let sourse_url = item["sourse_url"] as? String ?? ""
        
        let representations = item["representations"] as? NSDictionary
        let thumb_tiny = representations?["thumb_tiny"] as? String ?? ""
        let thumb_small = representations?["thumb_small"] as? String ?? ""
        let thumb = representations?["thumb"] as? String ?? ""
        let small = representations?["small"] as? String ?? ""
        let medium = representations?["medium"] as? String ?? ""
        let large = representations?["large"] as? String ?? ""
        let tall = representations?["tall"] as? String ?? ""
        let full = representations?["full"] as? String ?? ""
        
        let r = ImageResult.Metadata.Representations(thumb_tiny: thumb_tiny, thumb_small: thumb_small, thumb: thumb, small: small, medium: medium, large: large, tall: tall, full: full)
        
        let is_rendered = item["is_rendered"] as? Bool ?? false
        let is_optimized = item["is_optimized"] as? Bool ?? false
        
        let metadata = ImageResult.Metadata(id: id, created_at: created_at, updated_at: updated_at, duplicate_reports: duplicate_reports, first_seen_at: first_seen_at, file_name: file_name, description: description, uploader_id: uploader_id, uploader: uploader, image: image, score: score, upvotes: upvotes, downvotes: downvotes, faves: faves, comment_count: comment_count, tags: tags, tag_ids: tag_ids, width: width, height: height, aspect_ratio: aspect_ratio, original_format: original_format, mime_type: mime_type, sha512_hash: sha512_hash, orig_sha512_hash: orig_sha512_hash, sourse_url: sourse_url, representations: r, is_rendered: is_rendered, is_optimized: is_optimized)
        
        return Promise { fulfill, _ in
            fulfill(ImageResult(metadata: metadata))
        }
    }
    
    enum ImageParserError: Error {
        case imageTypeIsNotSupported(id: Int, status: ImageResult.Metadata.File_Ext)
    }
}

class UserParser: Parser {
    
    static func parse(data: Data) -> Promise<UserResult> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    
                    let name = json["name"] as? String ?? ""
                    let id = json["id"] as? Int ?? 0
                    let level = json["level"] as? Int ?? 0
                    
                    let avatar_id = json["avatar_id"] as? Int
                    
                    let metadata = UserResult.Metadata(name: name, id: id, level: level, avatar_id: avatar_id)
                    
                    fulfill(UserResult(metadata: metadata))
                    
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            } catch {
                reject(error)
            }
        }
    }
}

class TagParser: Parser, ParserForItem {
    static func parse(data: Data) -> Promise<TagResult> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    parse(dictionary: json).then { result -> Void in
                        fulfill(result)
                        }.catch { error in
                            reject(error)
                    }
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            }
        }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<TagResult> {
        let id = item["id"] as? String ?? ""
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
        
        return Promise { fulfill, _ in
            fulfill(TagResult(metadata: metadata))
        }
    }
}

class CommentParser {
    static func parse(data: Data) -> Promise<[CommentResult]> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary, let comments = json["comments"] as? Array<NSDictionary> {
                    var results = [CommentResult]()
                    
                    for comment in comments {
                        parse(dictionary: comment).then { result -> Void in
                            results.append(result)
                            }.catch { error -> Void in
                                
                        }
                    }
                    fulfill(results)
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            }
        }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<CommentResult> {
        let id = item["id"] as? Int ?? 0
        let body = item["body"] as? String ?? ""
        let author = item["author"] as? String ?? ""
        let image_id = item["image_id"] as? Int ?? 0
        let posted_at = item["posted_at"] as? String ?? ""
        let deleted = item["deleted"] as? Bool ?? false
        
        let metadata = CommentResult.Metadata(id: id, body: body, author: author, image_id: image_id, posted_at: posted_at, deleted: deleted)
        
        return Promise { fulfill, _ in
            fulfill(CommentResult(metadata: metadata))
        }
    }
}

/*
class FilterListParser: Parser {
    
    static func parse(data: Data, toResult result: FilterListResult) throws {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                
                var system_filters = [FilterResult]()
                var user_filters = [FilterResult]()
                var search_filters = [FilterResult]()
                
                if let items = json["system_filters"] as? [NSDictionary] {
                    for item in items {
                        try? system_filters.append(FilterParser.parseDictionary(item: item))
                    }
                }
                if let items = json["user_filters"] as? [NSDictionary] {
                    for item in items {
                        try? user_filters.append(FilterParser.parseDictionary(item: item))
                    }
                }
                if let items = json["search_filters"] as? [NSDictionary] {
                    for item in items {
                        try? search_filters.append(FilterParser.parseDictionary(item: item))
                    }
                }
                
                result.system_filters.append(contentsOf: system_filters)
                result.user_filters.append(contentsOf: user_filters)
                result.search_filters.append(contentsOf: search_filters)
                
            }
        } catch {
            throw error
        }
    }
    
}

class FilterParser: Parser {
    
    static func parse(data: Data) throws -> FilterResult {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                return try parseDictionary(item: json)
                
            } else {
                throw ParserError.CannotCastJsonIntoNSDictionary(data: data)
            }
        } catch {
            throw error
        }
        
    }
    
    static func parseDictionary(item json: NSDictionary) throws -> FilterResult {
        let id = json["id"] as? Int ?? 0
        let name = json["name"] as? String ?? ""
        let description = json["description"] as? String ?? ""
        var hidden_tag_ids = [Int]()
        if let items = json["hidden_tag_ids"] as? [Int] {
            for item in items {
                hidden_tag_ids.append(item)
            }
        }
        var spoilered_tag_ids = [Int]()
        if let items = json["spoilered_tag_ids"] as? [Int] {
            for item in items {
                spoilered_tag_ids.append(item)
            }
        }
        let spoilered_tags = json["spoilered_tags"] as? String ?? ""
        let hidden_tags = json["hidden_tags"] as? String ?? ""
        let hidden_complex = json["hidden_complex"] as? String ?? ""
        let spoilered_complex = json["spoilered_complex"] as? String ?? ""
        let isPublic = json["public"] as? Bool ?? false
        let system = json["system"] as? Bool ?? false
        let user_count = json["user_count"] as? Int ?? 0
        
        let metadata = FilterResult.Metadata(id: id, name: name, description: description, hidden_tag_ids: hidden_tag_ids, spoilered_tag_ids: spoilered_tag_ids, spoilered_tags: spoilered_tags, hidden_tags: hidden_tags, hidden_complex: hidden_complex, spoilered_complex: spoilered_complex, isPublic: isPublic, system: system, user_count: user_count)
        
        return FilterResult(metadata: metadata)
    }
    
}
*/





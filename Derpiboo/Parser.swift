//
//  Parser.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation

class Parser {
    
    enum ParserError: Error {
        case JsonDataCorrupted(data: Data)
        case CannotCastJsonIntoNSDictionary(data: Data)
    }
}

class ListParser: Parser {
    static func parse(data: Data, asType listType: ListRequester.ListType, toResult result: ListResult) throws {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                
                var tempResult = [ImageResult]()
                
                var key = ""
                switch listType {
                case .home: key = "images"
                case .search: key = "search"
                case .list(_): key = "images"
                    
                }
                
                if let items = json[key] as? Array<NSDictionary> {
                    
                    for item in items {
                        try? tempResult.append(ImageParser.parseDictionary(item: item))
                    }
                }
                
                result.add(results: tempResult)
                
            }
        } catch {
            throw error
        }
        
    }
}

class ImageParser: Parser {
    
    static func parse(data: Data) throws -> ImageResult {
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
    
    static func parseDictionary(item: NSDictionary) throws -> ImageResult {
        let id = item["id"] as? String ?? ""
        
        let created_at = item["created_at"] as? String ?? ""
        let updated_at = item["updated_at"] as? String ?? ""
        
        let duplicate_reports = item["duplicate_reports"] as? [AnyObject] ?? [AnyObject]()
        
        let first_seen_at = item["first_seen_at"] as? String ?? ""
        
        let file_name = item["file_name"] as? String ?? ""
        let description = item["description"] as? String ?? ""
        let uploader = item["uploader"] as? String ?? ""
        
        let image = item["image"] as? String ?? ""
        
        let score = item["score"] as? Int ?? 0
        let upvotes = item["upvotes"] as? Int ?? 0
        let downvotes = item["downvotes"] as? Int ?? 0
        let faves = item["faves"] as? Int ?? 0
        
        let comment_count = item["comment_count"] as? Int ?? 0
        
        let tags = item["tags"] as? String ?? ""
        let tag_ids = item["tag_ids"] as? [Int] ?? [Int]()
        
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
        
        let metadata = ImageResult.Metadata(id: id, created_at: created_at, updated_at: updated_at, duplicate_reports: duplicate_reports, first_seen_at: first_seen_at, file_name: file_name, description: description, uploader: uploader, image: image, score: score, upvotes: upvotes, downvotes: downvotes, faves: faves, comment_count: comment_count, tags: tags, tag_ids: tag_ids, width: width, height: height, aspect_ratio: aspect_ratio, original_format: original_format, mime_type: mime_type, sha512_hash: sha512_hash, orig_sha512_hash: orig_sha512_hash, sourse_url: sourse_url, representations: r, is_rendered: is_rendered, is_optimized: is_optimized)
        
        return ImageResult(metadata: metadata)
    }
    
}

class UserParser: Parser {
    
    static func parse(data: Data) throws -> UserResult {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                
                let name = json["name"] as? String ?? ""
                let id = json["id"] as? Int ?? 0
                let level = json["level"] as? Int ?? 0
                
                let avatar_id = json["avatar_id"] as? Int
                
                let metadata = UserResult.Metadata(name: name, id: id, level: level, avatar_id: avatar_id)
                
                return UserResult(metadata: metadata)
                
            } else {
                throw ParserError.CannotCastJsonIntoNSDictionary(data: data)
            }
        } catch {
            throw error
        }
    }
}

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






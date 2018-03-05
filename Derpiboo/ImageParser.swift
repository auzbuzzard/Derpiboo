//
//  ImageParser.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/13/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

struct ImageParser: ParserForItem {
    
    static func parse(dictionary item: NSDictionary) -> Promise<ImageResult> {
        guard let id = item["id"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "0", variable: "id")) }
        
        guard let created_at = item["created_at"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "created_at")) }
        guard let updated_at = item["updated_at"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "updated_at")) }
        
        guard let first_seen_at = item["first_seen_at"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "first_seen_at")) }
        
        guard let file_name = item["file_name"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "file_name")) }
        guard let description = item["description"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "description")) }
        guard let uploader = item["uploader"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "uploader")) }
        let uploader_id = item["uploader_id"] as? String
        
        guard let image = item["image"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "image")) }
        
        guard let score = item["score"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "score")) }
        guard let upvotes = item["upvotes"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "upvotes")) }
        guard let downvotes = item["downvotes"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "downvotes")) }
        guard let faves = item["faves"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "faves")) }
        
        guard let comment_count = item["comment_count"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "comment_count")) }
        
        guard let tags = item["tags"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "tags")) }
        guard let tag_ids = item["tag_ids"] as? [Int] else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "tag_ids")) }
        
        guard let width = item["width"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "width")) }
        guard let height = item["height"] as? Int else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "height")) }
        guard let aspect_ratio = item["aspect_ratio"] as? Double else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "aspect_ratio")) }
        
        guard let original_format = item["original_format"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "original_format")) }
        guard let mime_type = item["mime_type"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "mime_type")) }
        
        guard let sha512_hash = item["sha512_hash"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "sha512_hash")) }
        guard let orig_sha512_hash = item["orig_sha512_hash"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "orig_sha512_hash")) }
        guard let source_url = item["source_url"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "source_url")) }
        
        guard let representations = item["representations"] as? NSDictionary else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "representations")) }
        guard let thumb_tiny = representations["thumb_tiny"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "thumb_tiny")) }
        guard let thumb_small = representations["thumb_small"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "thumb_small")) }
        guard let thumb = representations["thumb"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "thumb")) }
        guard let small = representations["small"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "small")) }
        guard let medium = representations["medium"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "medium")) }
        guard let large = representations["large"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "large")) }
        guard let tall = representations["tall"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "tall")) }
        guard let full = representations["full"] as? String else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "full")) }
        
        let r = ImageResult.Metadata.Representations(thumb_tiny: thumb_tiny, thumb_small: thumb_small, thumb: thumb, small: small, medium: medium, large: large, tall: tall, full: full)
        
        guard let is_rendered = item["is_rendered"] as? Bool else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "is_rendered")) }
        guard let is_optimized = item["is_optimized"] as? Bool else { return Promise(error: ParserError.parserGuardFailed(id: "\(id)", variable: "is_optimized")) }
        
        let metadata = ImageResult.Metadata(id: "\(id)", created_at: created_at, updated_at: updated_at, first_seen_at: first_seen_at, file_name: file_name, description: description, uploader_id: uploader_id, uploader: uploader, image: image, score: score, upvotes: upvotes, downvotes: downvotes, faves: faves, comment_count: comment_count, tags: tags, tag_ids: tag_ids, width: width, height: height, aspect_ratio: aspect_ratio, original_format: original_format, mime_type: mime_type, sha512_hash: sha512_hash, orig_sha512_hash: orig_sha512_hash, source_url: source_url, representations: r, is_rendered: is_rendered, is_optimized: is_optimized)
        
        return Promise(value: ImageResult(metadata: metadata))
    }
}

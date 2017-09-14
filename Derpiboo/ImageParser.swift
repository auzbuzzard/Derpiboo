//
//  ImageParser.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/13/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

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
        let uploader_id = item["uploader_id"] as? String
        
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
        let source_url = item["source_url"] as? String ?? ""
        
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
        
        let metadata = ImageResult.Metadata(id: id, created_at: created_at, updated_at: updated_at, duplicate_reports: duplicate_reports, first_seen_at: first_seen_at, file_name: file_name, description: description, uploader_id: uploader_id, uploader: uploader, image: image, score: score, upvotes: upvotes, downvotes: downvotes, faves: faves, comment_count: comment_count, tags: tags, tag_ids: tag_ids, width: width, height: height, aspect_ratio: aspect_ratio, original_format: original_format, mime_type: mime_type, sha512_hash: sha512_hash, orig_sha512_hash: orig_sha512_hash, source_url: source_url, representations: r, is_rendered: is_rendered, is_optimized: is_optimized)
        
        return Promise { fulfill, _ in
            fulfill(ImageResult(metadata: metadata))
        }
    }
    
    enum ImageParserError: Error {
        case imageTypeIsNotSupported(id: Int, status: ImageResult.Metadata.File_Ext)
    }
}

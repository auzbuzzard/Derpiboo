//
//  Derpibooru.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/10/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class Derpibooru {
    
    let defaultSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    var dataTask: NSURLSessionDataTask?
    
    //Data
    
    var images = [DBImage]()
    private var searchTerm = ""
    func setSearchTerm(search: String) {
        searchTerm = search.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet()) ?? ""
    }
    
    private var currentPage: Int = 1
    private let perPage: Int = 48
    
    //LoadImages
    
    func clearImages() {
        images.removeAll()
    }
    
    func loadNewImages(completion: ErrorType? -> Void) {
        clearImages()
        currentPage = 1
        loadMoreImages() {
            error in
            completion(error)
        }
    }
    
    func loadMoreImages(completion: ErrorType? -> Void) {
        guard let url = NSURL(string: assembleURL()) else { print("url error"); return }
        
        currentPage += 1
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        dataTask = defaultSession.dataTaskWithURL(url) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let HTTPResponse = response as? NSHTTPURLResponse {
                if HTTPResponse.statusCode == 200 {
                    guard let data = data else { return completion(error) }
                    self.parseJSON(data)
                    completion(nil)
                } else {
                    print("HTTP Error (\(HTTPResponse.statusCode))")
                }
            }
        }
        dataTask?.resume()
    }
    
    //Private
    
    private func assembleURL() -> String {
        let userAPIKey = getUserAPIKey()
        let forcedSafeMode = userAPIKey == nil
        
        var u = "https://www.derpibooru.org/"
        u.appendContentsOf(searchTerm == "" && !forcedSafeMode ? "images.json":"search.json")
        u.appendContentsOf("?page=\(currentPage)")
        u.appendContentsOf("&perpage=\(perPage)")
        u.appendContentsOf(!forcedSafeMode ? "&key=\(userAPIKey!)":"")
        u.appendContentsOf(searchTerm == "" ? (forcedSafeMode ? "&q=safe" : "") : (forcedSafeMode ? "&q=\(searchTerm),safe" : "&q=\(searchTerm)"))
        
        return u
    }
    
    private func getUserAPIKey() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.boolForKey("userAPIKeySwitch") {
            guard let api = defaults.stringForKey("userAPIKey") else { return nil }
            return api
        } else {
            return nil
        }
    }
    
    private func parseJSON(data: NSData) {
        do {
            let result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            jsonToArray(result)
        } catch let JSONError {
            print(JSONError)
        }
    }
    
    private func jsonToArray(json: NSDictionary) {
        var jsonKey = ""
        //check if result is image or search by seeing if key total exists
        if (json["total"] as? Int) != nil {
            jsonKey = "search"
        } else {
            //result is image
            jsonKey = "images"
        }
        
        guard let results = json[jsonKey] as? [NSDictionary] else { print("json dict error"); return }
        
        for image in results {
            guard let id = image["id"] as? String else { print("Error parsing"); continue }
            guard let id_number = image["id_number"] as? Int else { print("Error parsing"); continue }
            
            let dbImage = DBImage(id: id, id_number: id_number)
            
            let created_at = image["created_at"] as? String
            dbImage.created_at = created_at
            let updated_at = image["updated_at"] as? String
            dbImage.updated_at = updated_at
            
            let duplicate_reports = image["duplicate_reports"] as? [AnyObject]
            dbImage.duplicate_reports = duplicate_reports
            
            let first_seen_at = image["first_seen_at"] as? String
            dbImage.first_seen_at = first_seen_at
            
            let file_name = image["file_name"] as? String
            dbImage.file_name = file_name
            let description = image["description"] as? String
            dbImage.description = description
            let uploader = image["uploader"] as? String
            dbImage.uploader = uploader

            let image_ = image["image"] as? String
            dbImage.image = image_
            
            let score = image["score"] as? Int
            dbImage.score = score
            let upvotes = image["upvotes"] as? Int
            dbImage.upvotes = upvotes
            let downvotes = image["downvotes"] as? Int
            dbImage.downvotes = downvotes
            let faves = image["faves"] as? Int
            dbImage.faves = faves
            
            let comment_count = image["comment_count"] as? Int
            dbImage.comment_count = comment_count
            
            let tags = image["created_at"] as? String
            dbImage.tags = tags
            let tag_ids = image["tag_ids"] as? [Int]
            dbImage.tag_ids = tag_ids
            
            let width = image["width"] as? Int
            dbImage.width = width
            let height = image["height"] as? Int
            dbImage.height = height
            let aspect_ratio = image["aspect_ratio"] as? Double
            dbImage.aspect_ratio = aspect_ratio
            
            let original_format = image["original_format"] as? String
            dbImage.original_format = original_format
            let mime_type = image["mime_type"] as? String
            dbImage.mime_type = mime_type
            
            let sha512_hash = image["sha512_hash"] as? String
            dbImage.sha512_hash = sha512_hash
            let orig_sha512_hash = image["orig_sha512_hash"] as? String
            dbImage.orig_sha512_hash = orig_sha512_hash
            let source_url = image["source_url"] as? String
            dbImage.source_url = source_url
            
            let thumb_tiny = image["thumb_tiny"] as? String
            dbImage.thumb_tiny = thumb_tiny
            let thumb_small = image["thumb_small"] as? String
            dbImage.thumb_small = thumb_small
            let thumb = image["thumb"] as? String
            dbImage.thumb = thumb
            let small = image["small"] as? String
            dbImage.small = small
            let medium = image["medium"] as? String
            dbImage.medium = medium
            let large = image["large"] as? String
            dbImage.large = large
            let tall = image["tall"] as? String
            dbImage.tall = tall
            let full = image["full"] as? String
            dbImage.full = full
            
             let is_rendered = image["is_rendered"] as? Bool
            dbImage.is_rendered = is_rendered
             let is_optimized = image["is_optimized"] as? Bool
            dbImage.is_optimized = is_optimized
            
            //array
            images.append(dbImage)
        }
    }
}

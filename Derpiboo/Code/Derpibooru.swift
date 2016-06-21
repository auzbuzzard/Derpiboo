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
    var isLoadingList = false
    var listName: String?
    func setDBToLoadingList(listName: String) {
        isLoadingList = true
        self.listName = listName
    }
    func getListNameReadable() -> String {
        guard let name = listName else { return "" }
        var s: String!
        switch name {
            case "top_scoring": s = "Top Scoring"
            case "top_commented": s = "Top Commented"
            case "all_time_top_scoring": s = "All Time Top Scoring"
            default: s = ""
        }
        return s
    }
    
    var profile: DBProfile? //{ get { return getProfileFromDefaults()} set { /*setProfileToDefaults(newValue)*/ self.profile = newValue } }
    var profileName: String? { get { return getUserNameFromDefaults() } set { setUserNameToDefaults(newValue!) } }
    
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
        var url: NSURL!
        if isLoadingList {
            if let listName = listName {
                guard let u = NSURL(string: assembleListURL(listName)) else { print("url error"); return }
                url = u
            } else { return }
        } else {
            guard let u = NSURL(string: assembleURL()) else { print("url error"); return }
            url = u
        }
        
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
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                        self.parseJSON(data)
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(nil)
                        }
                    }
                } else {
                    print("HTTP Error (\(HTTPResponse.statusCode))")
                }
            }
        }
        dataTask?.resume()
    }
    
    // other
    
    func loadProfile(profileName: String, completion: ErrorType? -> Void) {
        guard let url = NSURL(string: assembleProfileURL(profileName)) else { print("url error"); return }
        
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
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                        self.parseJSON(ofType: "profile", data: data)
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(nil)
                        }
                    }
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
    
    private func assembleListURL(listName: String) -> String {
        let userAPIKey = getUserAPIKey()
        let forcedSafeMode = userAPIKey == nil
        
        var u = "https://www.derpibooru.org/"
        u.appendContentsOf("lists/\(listName).json")
        u.appendContentsOf("?page=\(currentPage)")
        u.appendContentsOf("&perpage=\(perPage)")
        u.appendContentsOf(!forcedSafeMode ? "&key=\(userAPIKey!)":"")
        u.appendContentsOf(searchTerm == "" ? (forcedSafeMode ? "&q=safe" : "") : (forcedSafeMode ? "&q=\(searchTerm),safe" : "&q=\(searchTerm)"))
        
        return u
    }
    
    private func assembleProfileURL(profileName: String) -> String {
        var u = "https://www.derpibooru.org/"
        u.appendContentsOf("profiles/\(profileName).json")
        
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
    
    private func getUserNameFromDefaults() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let name = defaults.stringForKey("username") {
            return name
        } else {
            return nil
        }
    }
    
    private func setUserNameToDefaults(username: String?) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if username == nil { defaults.removeObjectForKey("username") }
        else { defaults.setValue(username, forKey: "username") }
    }
    
    private func getProfileFromDefaults() -> DBProfile? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let profile = defaults.objectForKey("profile") as! DBProfile? {
            return profile
        } else {
            return nil
        }
    }
    
//    private func setProfileToDefaults(profile: DBProfile?) {
//        let defaults = NSUserDefaults.standardUserDefaults()
//        
//        if profile == nil { defaults.removeObjectForKey("profile") }
//        else {
//            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(profile!)
//            defaults.setObject(encodedData, forKey: "profile")
//        }
//    }
    
    private func parseJSON(data: NSData) {
        parseJSON(ofType: "default", data: data)
    }
    
    private func parseJSON(ofType JSONType: String, data: NSData) {
        do {
            let result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            if JSONType == "default" {
                self.jsonToArray(result)
            } else if JSONType == "profile" {
                self.jsonToProfile(json: result)
            }
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
            
            let tags = image["tags"] as? String
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
            
            if let representations = image["representations"] as? NSDictionary {
                
                let thumb_tiny = representations["thumb_tiny"] as? String
                dbImage.thumb_tiny = thumb_tiny
                let thumb_small = representations["thumb_small"] as? String
                dbImage.thumb_small = thumb_small
                let thumb = representations["thumb"] as? String
                dbImage.thumb = thumb
                let small = representations["small"] as? String
                dbImage.small = small
                let medium = representations["medium"] as? String
                dbImage.medium = medium
                let large = representations["large"] as? String
                dbImage.large = large
                let tall = representations["tall"] as? String
                dbImage.tall = tall
                let full = representations["full"] as? String
                dbImage.full = full
                
            }
            
             let is_rendered = image["is_rendered"] as? Bool
            dbImage.is_rendered = is_rendered
             let is_optimized = image["is_optimized"] as? Bool
            dbImage.is_optimized = is_optimized
            
            //array
            images.append(dbImage)
        }
    }
    
    private func jsonToProfile(json result: NSDictionary) {
        guard let id = result["id"] as? Int else { print("Error parsing"); return }
        guard let name = result["name"] as? String else { print("Error parsing"); return }
        guard let slug = result["slug"] as? String else { print("Error parsing"); return }
        guard let role = result["role"] as? String else { print("Error parsing"); return }
        guard let description = result["description"] as? String else { print("Error parsing"); return }
        guard let avatar_url = result["avatar_url"] as? String else { print("Error parsing"); return }
        guard let created_at = result["created_at"] as? String else { print("Error parsing"); return }
        
        guard let comment_count = result["comment_count"] as? Int else { print("Error parsing"); return }
        guard let uploads_count = result["uploads_count"] as? Int else { print("Error parsing"); return }
        guard let post_count = result["post_count"] as? Int else { print("Error parsing"); return }
        guard let topic_count = result["topic_count"] as? Int else { print("Error parsing"); return }
        
        guard let awards = result["awards"] as? [NSDictionary] else { print("Error parsing"); return }
        var profileAwards = [DBProfileAwards]()
        for award in awards {
            guard let image_url = award["image_url"] as? String else { print("Error parsing"); continue }
            guard let title = award["title"] as? String else { print("Error parsing"); continue }
            guard let id = award["id"] as? Int else { print("Error parsing"); continue }
            guard let awarded_on = award["awarded_on"] as? String else { print("Error parsing"); continue }
            
            let dbProfileAwards = DBProfileAwards(image_url: image_url, title: title, id: id, awarded_on: awarded_on)
            profileAwards.append(dbProfileAwards)
        }
        
        profile = DBProfile(id: id, name: name, slug: slug, role: role, description: description, avatar_url: avatar_url, created_at: created_at, comment_count: comment_count, uploads_count: uploads_count, post_count: post_count, topic_count: topic_count, awards: profileAwards, avatar: nil)

        
        
    }

}

struct DBProfile {
    let id: Int
    let name: String
    let slug: String
    let role: String
    let description: String
    let avatar_url: String
    let created_at: String
    let comment_count: Int
    let uploads_count: Int
    let post_count: Int
    let topic_count: Int
    
    let awards: [DBProfileAwards]
    
    var avatar: UIImage?
    
    mutating func downloadAvatar(urlSession: NSURLSession, completion: (image: DBProfile, error: ErrorType?) -> Void) {
        guard let url = NSURL(string: "https:\(avatar_url)") else { print("download avatar url error, url: \(avatar_url)"); return }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let dataTask = urlSession.dataTaskWithURL(url) {
            data, response, error in
            
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            if let error = error {
                print(error.localizedDescription)
            } else if let HTTPResponse = response as? NSHTTPURLResponse {
                if HTTPResponse.statusCode == 200 {
                    guard let data = data else { return completion(image: self, error: error) }
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                        guard let image = UIImage(data: data) else { print("data to image error"); return completion(image: self, error: error) }
                        self.avatar = image
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(image: self, error: nil)
                        }
                    }
                    
                } else {
                    print("HTTP Error (\(HTTPResponse.statusCode)")
                }
            }
        }
        dataTask.resume()
    }
    
}

struct DBProfileAwards {
    let image_url: String
    let title: String
    let id: Int
    let awarded_on: String
}









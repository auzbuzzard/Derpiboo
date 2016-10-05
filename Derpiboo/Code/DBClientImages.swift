//
//  DBClientImages.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/23/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

protocol DBClientImagesProtocol {
    var images: [DBImage] { get }
    var searchTerm: String { get set }
    
    var listName: String! { get set }
    var mainList: [[Derpiboo.DBImage]] { get }
    
    func getListNameReadable(_ listName: String?) -> String
    func clearImages()
    
    func loadImages(ofType resultsType: DBClientImages.ImageResultsType, asNewResults: Bool, preloadThumbImage: Bool, urlSession: URLSession?, copyToClass: Bool, completion: ((_ images: [DBImage]?) -> Void)?)
    func loadImages(ofType resultsType: DBClientImages.ImageResultsType, asNewResults: Bool, listName: String?, preloadThumbImage: Bool, urlSession: URLSession?, copyToClass: Bool, completion: ((_ images: [DBImage]?) -> Void)?)
    
    func loadMainList(_ urlSession: URLSession?, copyToClass: Bool, completion: ((_ listNames: [[DBImage]]?) -> Void)?)
}

class DBClientImages: DBClient, DBClientImagesProtocol {
    
    enum ImageResultsType: String {
        case Home = "images", Search = "search", List = "lists", Watched = "watched", Favorites = "favourites", Upvotes = "upvoted", Uploaded = "uploaded", Default = ""
    }
    
    var listName: String!
    lazy var mainList = [[DBImage]]()
    
    enum ListName: String {
        case TopScoring = "top_scoring"
        case TopCommented = "top_commented"
        case AllTimeTopScoring = "all_time_top_scoring"
    }
    
    func getListNameReadable(_ listName: String?) -> String {
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
    
    //--- Data ---//
    
    lazy var images = [DBImage]()
    var searchTerm: String = "" {
        didSet {
            searchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? ""
        }
    }
    fileprivate var currentPage: Int = 1
    fileprivate let perPage: Int = 48
    
    //--- Loading Images ---//
    
    func clearImages() {
        images.removeAll()
    }
    
    func loadImages(ofType resultsType: ImageResultsType, asNewResults: Bool, preloadThumbImage: Bool, urlSession: URLSession?, copyToClass: Bool, completion: ((_ images: [DBImage]?) -> Void)?) {
        assert(resultsType != .List, "loadImages(ofType: .List) must use overloaded func with listName: String param.")
        loadImages(ofType: resultsType, asNewResults: asNewResults, listName: nil, preloadThumbImage: preloadThumbImage, urlSession: urlSession, copyToClass: copyToClass, completion: completion)
    }
    
    func loadImages(ofType resultsType: ImageResultsType, asNewResults: Bool, listName: String?, preloadThumbImage: Bool, urlSession: URLSession?, copyToClass: Bool, completion: ((_ images: [DBImage]?) -> Void)?) {
        
        if asNewResults {
            clearImages()
            currentPage = 1
        }
        
        guard let url = assembleURL(ofType: resultsType, listName: listName).toURL() else { print("loadMoreImages() error: cannot assemble valid url"); return }
        
        NetworkManager.loadData(url, urlSession: urlSession ?? clientSession, completion: {
            data in
            do {
                if let dict = try self.parseJSON(data) {
                    self.currentPage += 1
                    self.dictToDBImages(dictionary: dict, preloadThumbImage: preloadThumbImage, urlSession: urlSession, copyToClass: copyToClass, handler: completion)
                } else {
                    print("jsondata returns nil")
                }
                
            } catch {
                print("Error at parseJSON(data:) for loadImages() for url: \(url). JSONError:\n\(error)")
            }
        })
    }
    
    //--- Lists ---//
    
    func loadMainList(_ urlSession: URLSession?, copyToClass: Bool, completion: ((_ listNames: [[DBImage]]?) -> Void)?) {
        guard let url = assembleURL(ofType: .List, listName: "").toURL() else { print("loadList() error: URL error"); return }
        
        NetworkManager.loadData(url, urlSession: urlSession ?? clientSession, completion: { data in
            do {
                if let dict = try self.parseJSON(data) {
                    self.dictToMainList(dictionary: dict, urlSession: urlSession, copyToClass: copyToClass, handler: completion)
                } else {
                    print("jsondata returns nil for loadMainList()")
                }
            } catch {
                print("Error at parseJSON(data:) for loadLists() for url: \(url). JSONError:\n\(error)")
            }
        })
    }
    
    //--- URLs ---//
    
    fileprivate func assembleURL(ofType resultsType: ImageResultsType) -> String {
        return assembleURL(ofType: resultsType, listName: nil)
    }
    
    fileprivate func assembleURL(ofType resultsType: ImageResultsType, listName: String?) -> String {
        let userAPIKey = getUserAPIKey()
        let forcedSafeMode = userAPIKey == nil
        
        var u = "https://www.derpibooru.org/"
        
        switch resultsType {
        case .Home, .Search, .Default:
            
            u.append(searchTerm == "" && !forcedSafeMode ? "images.json":"search.json")
            
            
        case .List:
            
            guard let listName = listName else { print("assembleURL() error: listName is nil."); break }
            
            if listName == "" {
                u.append("lists.json")
            } else {
                u.append("lists/\(listName).json")
            }
            
        case .Watched:
            if forcedSafeMode {
                u = assembleURL(ofType: .Home)
            } else {
                u.append("images/watched.json")
            }
            
        case .Favorites:
            if forcedSafeMode {
                u = assembleURL(ofType: .Home)
            } else {
                u.append("images/favourites.json")
            }
            
        case .Upvotes:
            if forcedSafeMode {
                u = assembleURL(ofType: .Home)
            } else {
                u.append("images/upvoted.json")
            }
            
        case .Uploaded:
            if forcedSafeMode {
                u = assembleURL(ofType: .Home)
            } else {
                u.append("images/uploaded.json")
            }
        }
        
        u.append("?page=\(currentPage)")
        u.append("&perpage=\(perPage)")
        u.append(!forcedSafeMode ? "&key=\(userAPIKey!)":"")
        u.append(searchTerm == "" ? (forcedSafeMode ? "&q=safe" : "") : (forcedSafeMode ? "&q=\(searchTerm),safe" : "&q=\(searchTerm)"))
        
        return u
    }
    
    //--- Creating Data from Json dictionaries ---//
    
    fileprivate func dictToDBImages(dictionary json: NSDictionary, preloadThumbImage: Bool, urlSession: URLSession?, copyToClass: Bool, handler: (([DBImage]) -> Void)?) {
        
        var returnResult = handler == nil ? images : [DBImage]()
        
        //check if result is image or search by seeing if key total exists
        let jsonKey = (json["total"] as? Int) != nil ? "search" : "images"
        
        guard let results = json[jsonKey] as? [NSDictionary] else { print("json dict error"); return }
        
        for image in results {
            
            guard let id = image["id"] as? String else { print("Error parsing"); continue }
            //guard let id_number = image["id_number"] as? Int else { print("Error parsing"); continue } //doesn't seem to exists anymore after jun28
            
            var dbImage = DBImage(id: id)
            
            dictToDBImage(dictionary: image, dbImage: &dbImage)
            
            if preloadThumbImage {
                dbImage.downloadImage(ofSizeType: .thumb, urlSession: urlSession, completion: nil)
            }
            
            returnResult.append(dbImage)
            
            if copyToClass && handler != nil {
                images.append(dbImage)
            }
        }
        handler?(returnResult)
    }
    
    
    fileprivate func dictToMainList(dictionary json: NSDictionary, urlSession: URLSession?, copyToClass: Bool, handler: (([[DBImage]]) -> Void)?) {
        
        var returnResults = handler == nil ? mainList : [[DBImage]]()
        
        var returnResult = [DBImage]()
        
        let strings = [ListName.TopScoring.rawValue, ListName.TopCommented.rawValue, ListName.AllTimeTopScoring.rawValue]
        
        for string in strings {
            
            guard let topScoring = json[string] as? [NSDictionary] else { print("json dict error"); return }
            
            for image in topScoring {
                guard let id = image["id"] as? String else { print("Error parsing"); continue }
                //guard let id_number = image["id_number"] as? Int else { print("Error parsing"); continue }
                
                var dbImage = DBImage(id: id)
                
                dictToDBImage(dictionary: image, dbImage: &dbImage)
                
                returnResult.append(dbImage)
                
            }
            returnResults.append(returnResult)
            if copyToClass && handler != nil {
                mainList.append(returnResult)
            }
            returnResult.removeAll()
        }
        handler?(returnResults)
    }
    
    fileprivate func dictToDBImage(dictionary image: NSDictionary, dbImage: inout DBImage) {
        
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
    }

    
}

















//
//  Derpibooru.swift
//  Derpiboo
//
//  Created by Austin Chau on 12/22/15.
//  Copyright © 2015 Austin Chau. All rights reserved.
//

import UIKit

protocol DerpibooruDataSource {
    var imageArray: [DBImage] { get }
    var searchTerm: String? { get set }
    func setDBImageThumbailDelegate(delegate: DBImageThumbnailDelegate)
    func loadNewImages(query: String?, completion: ErrorType? -> Void)
    func loadMoreImages(query: String?, completion: ErrorType? -> Void)
}

// ------------------------------------
// Derpibooru - Singleton class that represents the Derpibooru website. Responsible for fetching and acting as the array source of the returned image results
// ------------------------------------

class Derpibooru: NSObject, DerpibooruDataSource {
    
    static var defaultInstance = Derpibooru()
    static var listInstance = Derpibooru()
    
    // ------------------------------------
    // MARK: - class setup
    // ------------------------------------
    
    let defaults = NSUserDefaults.standardUserDefaults()
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    // ------------------------------------
    // MARK: - Variables
    // ------------------------------------
    
    var imageArray = [DBImage]()
    
    var searchTerm: String?
    
    private var page = 1
    private let perPage = 50
    
    // ------------------------------------
    // MARK: - Useful stuff
    // ------------------------------------
    
    private enum DBJsonKey: String {
        case Featured = "images"
        case Search = "search"
    }
    
    private var dbImageThumbailDelegate: DBImageThumbnailDelegate?
    
    func setDBImageThumbailDelegate(delegate: DBImageThumbnailDelegate) {
        dbImageThumbailDelegate = delegate
    }
    
    // ------------------------------------
    // MARK: - Method - Fetch JSON
    // ------------------------------------
    
    private func fetchJSON(request: NSURLRequest, completion: (result: NSDictionary?, error: ErrorType?) -> Void) {
        session.dataTaskWithRequest(request) { data, response, error in
            //check if error is nil 
            guard error == nil else { completion(result: nil, error: error); return }
            //check http status code
            if let response = response as? NSHTTPURLResponse {
                if let HTTPError = self.checkHTTPResponse(response) {
                    completion(result: nil, error: HTTPError)
                    return
                }
            }
            //check if data is intact
            guard let data = data else { completion(result: nil, error: error); return }
            //JSON parsing
            do {
                let result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                completion(result: result, error: nil)
            } catch let JSONError {
                completion(result: nil, error: JSONError)
            }
        }.resume()
    }
        
    private func jsonDictToImageArray(jsonDict: NSDictionary, jsonKey: DBJsonKey) {
        if let images = jsonDict[jsonKey.rawValue] as? [NSDictionary] {
            for image in images {
                //core stuff
                guard let id = image["id"] as? String else { print("error parsing"); continue }
                guard let id_number = image["id_number"] as? Int else { print("error parsing"); continue }
                guard let imageURLString = image["image"] as? String else { print("error parsing"); continue }
                guard let thumbURLString = image["representations"]?["thumb_small"] as? String else { print("error parsing"); continue }
                let imageURL = NSURL(string: "https:\(imageURLString)")!
                let thumbURL = NSURL(string: "https:\(thumbURLString)")!
                
                let dbImage = DBImage(id: id, id_number: id_number, imageURL: imageURL, thumbURL: thumbURL, session: session)
                dbImage.downloadThumb()
                
                //thumbnailDelegate
                dbImage.thumbnailDelegate = dbImageThumbailDelegate
                
                //scores
                guard let upvote = image["upvotes"] as? Int else { continue }
                guard let downvote = image["downvotes"] as? Int else { continue }
                guard let favvote = image["faves"] as? Int else { continue }
                
                dbImage.scores = DBImageScores(upvote: upvote, downvote: downvote, favvote: favvote)
                
                //metadata
                guard let description = image["description"] as? String else { continue }
                guard let uploader = image["uploader"] as? String else { continue }
                guard let tags = image["tags"] as? String else { continue }
                
                dbImage.metadata = DBImageMetadata(description: description, uploader: uploader, tags: tags)
                
                //dimensions
                guard let width = image["width"] as? Int else { continue }
                guard let height = image["height"] as? Int else { continue }
                
                dbImage.dimensions = DBImageDimensions(width: width, height: height)
                
                //add to array
                imageArray.append(dbImage)
            }
        }
    }
    
    // ------------------------------------
    // MARK: - Method - Load Images
    // ------------------------------------
    
    func loadNewImages(query: String?, completion: ErrorType? -> Void) {
        imageArray.removeAll()
        page = 1
        loadMoreImages(query) { error in
            completion(error)
        }
    }
    
    func loadMoreImages(var query: String?, completion: ErrorType? -> Void) {
        let pageAPI = "?page=\(page)"
        let perPageAPI = "&perpage=\(perPage)"
        
        //login information using the user API key
        var userAPI = ""
        var forceNotLoggedInUserSafeMode: Bool = true
        if let api = getUserAPI() {
            userAPI = "&key=\(api)"
            forceNotLoggedInUserSafeMode = false
        }
        
        //inject query if query exist, also setup jsonKey which tells the JSON parser what returned structure will be (derpibooru returns different key using different access api)
        var jsonKey: DBJsonKey!
        var queryAPI = ""
        
        if query != nil {
            if forceNotLoggedInUserSafeMode {
                query! += ",safe"
            }
            let escapedString = query!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
            queryAPI = "&q=\(escapedString!)"
            jsonKey = .Search
        } else {
            if forceNotLoggedInUserSafeMode {
                let safeModeQuery = "safe"
                queryAPI = "&q=\(safeModeQuery)"
                jsonKey = .Search
            } else {
                jsonKey = .Featured
            }
        }
        
        //combine APIs into an NSURL
        let url = NSURL(string: "https:" + "//" + "www.derpibooru.org" + "/\(jsonKey.rawValue).json" + pageAPI + perPageAPI + userAPI + queryAPI)!
        let request = NSURLRequest(URL: url)
        
        //Hand the NSURLRequest to the method that fetch the JSON
        fetchJSON(request) { result, error in
            if error != nil {
                self.errorHandling(error!)
                completion(error)
            } else {
                self.jsonDictToImageArray(result!, jsonKey: jsonKey)
                completion(nil)
            }
        }
        
        //Update the page count
        page++
    }
    
    // ------------------------------------
    // MARK: - Method - HTTP response
    // ------------------------------------
    
    private func checkHTTPResponse(response: NSHTTPURLResponse) -> ErrorType? {
        if response.statusCode >= 200 && response.statusCode <= 300 {
            return nil
        } else {
            return HTTPError.HTTPStatusCodeNon200
        }
        
    }
    
    // ------------------------------------
    // MARK: - Method - Check API
    // ------------------------------------
    
    private func getUserAPI() -> String? {
        if defaults.boolForKey("userAPIKeySwitch") {
            if let api = defaults.stringForKey("userAPIKey") {
                return api
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    // ------------------------------------
    // MARK: - Method - Error Handling
    // ------------------------------------
    
    func errorHandling(error: ErrorType) {
        print(error)
    }
}

enum HTTPError: ErrorType {
    case HTTPStatusCodeNon200
}

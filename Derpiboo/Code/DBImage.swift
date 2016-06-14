//
//  DBImage.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/10/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class DBImage {
    
    //Data
    let id: String
    let id_number: Int
    
    var created_at: String?
    var updated_at: String?
    
    var duplicate_reports: [AnyObject]?
    
    var first_seen_at: String?
    
    var file_name: String?
    var description: String?
    var uploader: String?
    
    var image: String?
    
    var score: Int?
    var upvotes: Int?
    var downvotes: Int?
    var faves: Int?
    
    var comment_count: Int?
    
    var tags: String?
    var tag_ids: [Int]?
    
    var width: Int?
    var height: Int?
    var aspect_ratio: Double?
    
    var original_format: String?
    var mime_type: String?
    
    var sha512_hash: String?
    var orig_sha512_hash: String?
    var source_url: String?
    
    //representations
    var thumb_tiny: String?
    var thumb_small: String?
    var thumb: String?
    var small: String?
    var medium: String?
    var large: String?
    var tall: String?
    var full: String?
    
    var is_rendered: Bool?
    var is_optimized: Bool?
    
    var thumbImage: UIImage?
    var largeImage: UIImage?
    var fullImage: UIImage?
    
    enum ImageSizeType {
        case thumb
        case large
        case full
    }
    
    init(id: String, id_number: Int) {
        self.id = id
        self.id_number = id_number
    }
    
    func getImage(ofSizeType: ImageSizeType, urlSession: NSURLSession, completion: (image: DBImage, error: ErrorType?) -> Void) -> UIImage? {
        if let image = getImageOfSizeType(ofSizeType) {
            print("has image")
            return image
        } else {
            print("dont have image")
            downloadImage(ofSizeType, urlSession: urlSession) {
                image, error in
                completion(image: image, error: error)
            }
            return nil
        }
    }
    
    func getImageOfSizeType(ofSizeType: ImageSizeType) -> UIImage? {
        switch ofSizeType {
        case .thumb: return thumbImage
        case.large: return largeImage
        case.full: return fullImage
        }
    }
    
    private func setImageOfSizeType(ofSizeType: ImageSizeType, image: UIImage) {
        switch ofSizeType {
        case .thumb: thumbImage = image
        case.large: largeImage = image
        case.full: fullImage = image
        }
    }
    
    private func getImageURLOfSizeType(ofSizeType: ImageSizeType) -> String? {
        switch ofSizeType {
        case .thumb: return thumb_tiny
        case .large: return large
        case .full: return image
        }
    }
    
    func downloadImage(ofSizeType: ImageSizeType, urlSession: NSURLSession, completion: (image: DBImage, error: ErrorType?) -> Void) {
        //guard let u = thumb else { print("doo"); return }
        guard let u = getImageURLOfSizeType(ofSizeType) else { print("download thumbnail url error, \(getImageOfSizeType(ofSizeType))"); return }
        guard let url = NSURL(string: "https:\(u)") else { print("download thumbnail url error, url: \(u)"); return }
        
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
                    guard let image = UIImage(data: data) else { print("data to image error"); return completion(image: self, error: error) }
                    self.setImageOfSizeType(ofSizeType, image: image)
                    completion(image: self, error: nil)
                    
                } else {
                    print("HTTP Error (\(HTTPResponse.statusCode)")
                }
            }
        }
        dataTask.resume()
    }
    
}
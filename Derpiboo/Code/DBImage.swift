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
    
    var comments: [DBComment]?
    
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
    
    func getImage(ofSizeType sizeType: ImageSizeType, urlSession: NSURLSession?, completion: (image: DBImage?) -> Void) -> UIImage? {
        if let image = getImage(ofSizeType: sizeType) {
            return image
        } else {
            downloadImage(ofSizeType: sizeType, urlSession: urlSession, completion: completion)
            return nil
        }
    }
    
    func getImage(ofSizeType sizeType: ImageSizeType) -> UIImage? {
        switch sizeType {
        case .thumb: return thumbImage
        case.large: return largeImage
        case.full: return fullImage
        }
    }
    
    func setImage(ofSizeType sizeType: ImageSizeType, image: UIImage) {
        switch sizeType {
        case .thumb: thumbImage = image
        case.large: largeImage = image
        case.full: fullImage = image
        }
    }
    
    private func getImageURL(ofSizeType sizeType: ImageSizeType) -> String? {
        switch sizeType {
        case .thumb: return thumb
        case .large: return large
        case .full: return image
        }
    }
    
    func downloadImage(ofSizeType sizeType: ImageSizeType, urlSession: NSURLSession?, completion: ((image: DBImage?) -> Void)?) {
        downloadImage(ofSizeType: sizeType, urlSession: urlSession, useCustomDelegate: false, completion: completion)
    }
    
    func downloadImage(ofSizeType sizeType: ImageSizeType, urlSession: NSURLSession?, useCustomDelegate: Bool, completion: ((image: DBImage?) -> Void)?) {
        guard let u = getImageURL(ofSizeType: sizeType) else { print("getImageURL() error at DBImage"); return }
        guard let url = "https:\(u)".toURL() else { print("DBImage downloadImage() url error, for dbImage: \(id_number), for url: \(getImageURL(ofSizeType: sizeType))"); return }
        
        if useCustomDelegate {
            NetworkManager.loadData(url, urlSession: urlSession)
        } else {
            NetworkManager.loadData(url, urlSession: urlSession, completion: { data in
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
                    
                    guard let image = UIImage(data: data) else { print("data to image error");completion?(image: nil) ; return }
                    self.setImage(ofSizeType: sizeType, image: image)
                    
                    completion?(image: self)
                }
            })
        }
        
    }
}











////
////  DBImage.swift
////  Derpiboo
////
////  Created by Austin Chau on 12/22/15.
////  Copyright © 2015 Austin Chau. All rights reserved.
////
//
//import UIKit
//
//protocol DBImageDelegate: DBImageThumbnailDelegate, DBImageFullImageDelegate { }
//
//protocol DBImageThumbnailDelegate {
//    func thumbnailDidFinishDownloading(dbImage: DBImage)
//}
//
//protocol DBImageFullImageDelegate {
//    func fullImageDidFinishDownloading(dbImage: DBImage)
//}
//
//// ------------------------------------
//// MARK: - Class that defines each image instance from derpibooru
//// ------------------------------------
//
//class DBImage: NSObject {
//    
//    // ------------------------------------
//    // MARK: - Class Variables
//    // ------------------------------------
//    
//    let session: NSURLSession
//    
//    var thumbnailDelegate: DBImageThumbnailDelegate?
//    var fullImageDelegate: DBImageFullImageDelegate?
//    
//    // ------------------------------------
//    // MARK: - All data fields
//    // ------------------------------------
//    
//    let id: String
//    let id_number: Int
//    
//    var imageURL: NSURL
//    var thumbURL: NSURL
//    
//    var thumbnail: UIImage?
//    var fullImage: UIImage?
//    
//    var scores: DBImageScores?
//    var metadata: DBImageMetadata?
//    var dimensions: DBImageDimensions?
//    
//    init(id: String, id_number: Int, imageURL:NSURL, thumbURL:NSURL, session: NSURLSession) {
//        self.id = id
//        self.id_number = id_number
//        self.imageURL = imageURL
//        self.thumbURL = thumbURL
//        self.session = session
//    }
//    
//    // ------------------------------------
//    // MARK: - Methods - NSURLSession
//    // ------------------------------------
//    
//    private func getDataFromURL(url: NSURL, completion:((data: NSData?, response: NSURLResponse?, error: ErrorType? ) -> Void)) {
//        session.dataTaskWithURL(url) { (data, response, error) in
//            completion(data: data, response: response, error: error)
//            }.resume()
//    }
//    
//    // ------------------------------------
//    // MARK: - Methods - download thumbnail
//    // ------------------------------------
//    
//    func downloadThumb() {
//        if thumbnail == nil {
//            getDataFromURL(thumbURL) { data, response, error in
//                guard let data = data where error == nil else { self.errorHandling(error!); return }
//                self.thumbnail = UIImage(data: data)
//                self.thumbnailDelegate?.thumbnailDidFinishDownloading(self)
//            }
//        }
//    }
//    
//    func downloadThumb(completion:(response: NSURLResponse?, error: ErrorType?) -> Void) {
//        if thumbnail == nil {
//            getDataFromURL(thumbURL) { data, response, error in
//                guard let data = data where error == nil else { completion(response: response, error: error); return }
//                self.thumbnail = UIImage(data: data)
//                completion(response: response, error: nil)
//            }
//        }
//    }
//    
//    // ------------------------------------
//    // MARK: - Methods - download full image
//    // ------------------------------------
//    
//    func downloadFullImage() {
//        if fullImage == nil {
//            getDataFromURL(imageURL) { data, response, error in
//                guard let data = data where error == nil else { self.errorHandling(error!); return }
//                self.fullImage = UIImage(data: data)
//                self.fullImageDelegate?.fullImageDidFinishDownloading(self)
//            }
//        }
//    }
//    
//    func downloadFullImage(completion:(response: NSURLResponse?, error: ErrorType?) -> Void) {
//        if fullImage == nil {
//            getDataFromURL(imageURL) { data, response, error in
//                guard let data = data where error == nil else { completion(response: response, error: error); return }
//                self.fullImage = UIImage(data: data)
//                completion(response: response, error: nil)
//            }
//        }
//    }
//    
//    // ------------------------------------
//    // MARK: - Methods - Image Resizing
//    // ------------------------------------
//    
////    func resizeImage(image: UIImage, type: DBImageType) -> (UIImage, DBImageType) {
////        
////    }
//    
//    // ------------------------------------
//    // MARK: - Memory and Data Management
//    // ------------------------------------
//    
//    func didReceiveMemoryWarning() {
//        fullImage = nil
//    }
//    
//    // ------------------------------------
//    // MARK: - Methods - Error Handling
//    // ------------------------------------
//    
//    private func errorHandling(error: ErrorType) {
//        print(error)
//    }
//    
//}
//
//struct DBImageScores {
//    var upvote: Int?
//    var downvote: Int?
//    var favvote: Int?
//    
//    init() { }
//    
//    init(upvote: Int, downvote: Int, favvote: Int) {
//        self.upvote = upvote
//        self.downvote = downvote
//        self.favvote = favvote
//    }
//}
//
//struct DBImageMetadata {
//    var description: String?
//    var uploader: String?
//    var tags: String?
//    
//    init() { }
//    
//    init(description: String, uploader: String, tags: String) {
//        self.description = description
//        self.uploader = uploader
//        self.tags = tags
//    }
//}
//
//struct DBImageDimensions {
//    var width: Int
//    var height: Int
//    
//    init(width: Int, height: Int) {
//        self.width = width
//        self.height = height
//    }
//}
//
//enum DBImageType {
//    case Thumbnail
//    case FullImage
//    case FullImageOptimized
//    case ThumbnailOptimized
//}
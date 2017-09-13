//
//  Cache.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit
import Carlos

// Mark: Protocols
// For External Class Conformance

protocol UsingImageCache {
    var imageCache: ImageCache { get }
}
extension UsingImageCache {
    var imageCache: ImageCache { return ImageCache.shared }
}
protocol UsingUserCache {
    var userCache: UserCache { get }
}
extension UsingUserCache {
    var userCache: UserCache { return UserCache.shared }
}
protocol UsingImageResultCache {
    var imageResultCache: ImageResultCache { get }
}
extension UsingImageResultCache {
    var imageResultCache: ImageResultCache { return ImageResultCache.shared }
}
protocol UsingTagCache {
    var tagCache: TagCache { get }
}
extension UsingTagCache {
    var tagCache: TagCache { return TagCache.shared }
}

// For internal class conformance
protocol CacheClass { }
//extension CacheClass { }

class Cache {
    static var image: ImageCache { return ImageCache.shared }
    static var imageResult: ImageResultCache { return ImageResultCache.shared }
    static var user: UserCache { return UserCache.shared }
    static var tag: TagCache { return TagCache.shared }
}

class ImageCache: CacheClass {
    class DataWrapper: NSObject {
        let data: Data
        init(_ data: Data) { self.data = data }
    }
    
    fileprivate static let shared = ImageCache()
    private init() { images.totalCostLimit = 750 * 1024 * 1024 /* 750MB */ }
    
    private lazy var images = NSCache<NSString, DataWrapper>()
    
    func getImageData(for id: String, size: ImageResult.Metadata.ImageSize) -> Promise<Data> {
        return Promise { fulfill, reject in
            if let image = images.object(forKey: "\(id)_\(size.rawValue)" as NSString) {
                fulfill(image.data)
            } else {
                reject(CacheError.noImageInStore(id: id))
            }
        }
    }
    
    func setImageData(_ imageData: Data, id: String, size: ImageResult.Metadata.ImageSize) -> Promise<Void> {
        return Promise { fulfill, reject in
            let cost = imageData.cost
            images.setObject(DataWrapper(imageData), forKey: "\(id)_\(size.rawValue)" as NSString, cost: cost)
            fulfill()
        }
    }
    
    enum CacheError: Error {
        case noImageInStore(id: String)
    }
}

class ImageResultCache: CacheClass {
    fileprivate static let shared = ImageResultCache()
    private init() { }
    
    private lazy var results = Dictionary<String, ImageResult>()
    
    func getImageResult(for id: String) -> Promise<ImageResult> {
        return Promise { fulfill, reject in
            if let image = results[id] {
                fulfill(image)
            } else {
                reject(CacheError.noImageResultInStore(id: id))
            }
        }
    }
    
    func setImageResult(_ result: ImageResult) -> Promise<Void> {
        return Promise { fulfill, reject in
            results.updateValue(result, forKey: result.id)
            fulfill()
        }
    }
    
    enum CacheError: Error {
        case noImageResultInStore(id: String)
    }
}

class UserCache: CacheClass {
    fileprivate static let shared = UserCache()
    private init() { }
    lazy var users = Dictionary<String, UserResult>()
    
    func getUser(for id: Int) -> Promise<UserResult> {
        return Promise { fulfill, reject in
            if let user = users["\(id)"] {
                fulfill(user)
            } else {
                reject(CacheError.noUserInStore(id: id))
            }
        }
    }
    
    func setUser(_ user: UserResult) -> Promise<Void> {
        return Promise { fulfill, reject in
            users.updateValue(user, forKey: "\(user.id)")
            fulfill()
        }
    }
    
    enum CacheError: Error {
        case noUserInStore(id: Int)
    }
}

class TagCache: CacheClass {
    fileprivate static let shared = TagCache()
    private init() { }
    lazy var tags = Dictionary<String, TagResult>()
    
    func getTag(for id: String) -> Promise<TagResult> {
        return Promise { fulfill, reject in
            if let tag = tags[id] {
                fulfill(tag)
            } else {
                reject(CacheError.noTagInStore(id: id))
            }
        }
    }
    
    func setTag(_ tag: TagResult) -> Promise<Void> {
        return Promise { fulfill, reject in
            tags.updateValue(tag, forKey: tag.id)
            fulfill()
        }
    }
    
    enum CacheError: Error {
        case noTagInStore(id: String)
    }
}

fileprivate class CacheObject<T> {
    var object:T
    var timestamp: Date
    var name: String
    
    init(name: String, object:T) {
        self.name = name
        self.object = object
        timestamp = Date()
    }
}


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

// For internal class conformance
protocol CacheClass { }
//extension CacheClass { }

class Cache {
    private init() { }
    static var image: ImageCache { return ImageCache.shared }
    static var imageResult: ImageResultCache { return ImageResultCache.shared }
    static var user: UserCache { return UserCache.shared }
    static var tag: TagCache { return TagCache.shared }
}

class ImageCache: CacheClass {
    private class DataWrapper: NSObject {
        let data: Data
        init(_ data: Data) { self.data = data }
    }
    
    fileprivate static let shared = ImageCache()
    private init() { images.totalCostLimit = 750 * 1024 * 1024 /* 750MB */ }
    
    private lazy var images = NSCache<NSString, DataWrapper>()
    
    func getImageData(for id: String, size: ImageResult.Metadata.ImageSize) -> Promise<Data> {
        guard let image = images.object(forKey: "\(id)_\(size.rawValue)" as NSString) else { return Promise(error: CacheError.noImageInStore(id: id)) }
        return Promise(value: image.data)
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
    
    private let writeQueue = DispatchQueue(label: "derpiboo.UserCache.writeQueue")
    lazy var users = Dictionary<String, UserResult>()
    lazy private var userSlug = Dictionary<String, Int>()
    
    func getUser(for id: Int) -> Promise<UserResult> {
        return writeQueue.promise {
            guard let user = self.users["\(id)"] else { throw CacheError.noUserInStore(id: id) }
            return user
        }
    }
    
    func getUser(for slug: String) -> Promise<UserResult> {
        guard let id = userIdFromSlug(slug) else { return Promise(error: CacheError.slugNotConvertible(slug: slug)) }
        return getUser(for: id)
    }
    
    func setUser(_ user: UserResult) -> Promise<Void> {
        return writeQueue.promise {
            self.users.updateValue(user, forKey: "\(user.id)")
            self.userSlug.updateValue(user.id, forKey: user.metadata.slug)
            return
        }
    }
    
    private func userIdFromSlug(_ slug: String) -> Int? {
        return userSlug[slug]
    }
    
    enum CacheError: Error {
        case slugNotConvertible(slug: String)
        case noUserInStore(id: Int)
    }
}

class TagCache: CacheClass {
    fileprivate static let shared = TagCache()
    private init() { }
    lazy var tags = Dictionary<Int, TagResult>()
    
    func getTag(for id: Int) -> Promise<TagResult> {
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
        case noTagInStore(id: Int)
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


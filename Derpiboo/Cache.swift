//
//  Cache.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class Cache {
    
    static let shared = Cache()
    private init() { }
    
    lazy var images = Dictionary<String, UIImage>()
    lazy var users = Dictionary<String, UserResult>()
    
    func getImage(size: ImageResult.Metadata.SizeType, id: String) throws -> UIImage {
        if let image = images["\(size.rawValue)_\(id)"] {
            return image
        } else {
            throw CacheImageError.NoImageInStore(id: "\(id)")
        }
    }
    
    func setImage(size: ImageResult.Metadata.SizeType, image: UIImage, forID id: String) throws {
        images.updateValue(image, forKey: "\(size.rawValue)_\(id)")
    }
    
    func getUser(id: Int) throws -> UserResult {
        if let user = users["\(id)"] {
            return user
        } else {
            throw CacheUserError.NoUserInStor(id: "\(id)")
        }
    }
    
    func setUser(user: UserResult, forId id: Int) throws {
        users.updateValue(user, forKey: "\(id)")
    }
    
    enum CacheImageError: Error {
        case NoImageInStore(id: String)
        
        func string() -> String {
            switch self {
            case .NoImageInStore(let i):
                return "Caching Image Error: There is no image in cache for id: \(i)"
            }
        }
    }
    
    enum CacheUserError: Error {
        case NoUserInStor(id: String)
    }
}

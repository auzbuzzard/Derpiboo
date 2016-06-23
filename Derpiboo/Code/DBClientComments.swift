//
//  DBClientComments.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/23/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

protocol DBClientCommentsProtocol {
    var comments: [DBComment] { get }
    func clearComments()
    func loadComments(image_id_number id_number: Int, preloadProfile: Bool, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((comments: [DBComment]) -> Void)?)
}

class DBClientComments: DBClient {
    
    //--- Data ---//
    
    lazy var comments = [DBComment]()
    
    private var currentPage: Int = 1
    private let perPage: Int = 48
    
    //--- Load Comments ---//
    
    func clearComments() {
        comments.removeAll()
    }
    
    func loadComments(image_id_number id_number: Int, preloadProfile: Bool, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((comments: [DBComment]) -> Void)?) {
        
        guard let url = "https://www.derpibooru.org/\(id_number).json?comments=true".toURL() else { print("loadComments() error: cannot assemble valid url for image_id_number: \(id_number)"); return }
        
        NetworkManager.loadData(url, urlSession: urlSession ?? clientSession, completion: { data in
            do {
                if let dict = try self.parseJSON(data) {
                    self.dictToDBComments(dictionary: dict, preloadProfile: preloadProfile, preloadAvatar: preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: handler)
                } else {
                    print("jsondata returns nil")
                }
                
            } catch {
                print("Error at parseJSON(data:) for loadComments() for url: \(url). JSONError:\n\(error)")
            }

        })
    }
    
    //--- Creating Data from Json dictionaries ---//
    
    private func dictToDBComments(dictionary result: NSDictionary, preloadProfile: Bool, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ([DBComment] -> Void)?) {
        
        guard let results = result["comments"] as? [NSDictionary] else { print("Error parsing"); return }
        
        var array: [DBComment] = handler == nil ? comments : [DBComment]()
        
        for comment in results {
            guard let id = comment["id"] as? Int else { print("Error parsing"); return }
            guard let body = comment["body"] as? String else { print("Error parsing"); return }
            guard let author = comment["author"] as? String else { print("Error parsing"); return }
            guard let image_id = comment["image_id"] as? Int else { print("Error parsing"); return }
            guard let posted_at = comment["posted_at"] as? String else { print("Error parsing"); return }
            guard let deleted = comment["deleted"] as? Bool else { print("Error parsing"); return }
            
            var c = DBComment(id: id, body: body, author: author, image_id: image_id, posted_at: posted_at, deleted: deleted, authorProfile: nil)
            
            if preloadProfile {
                c.downloadProfile(nil, preloadAvatar: preloadAvatar, urlSession: urlSession, copyToClass: false, completion: nil)
            }
            
            array.append(c)
            
            if copyToClass && handler != nil {
                comments.append(c)
            }
        }
        handler?(array)
    }
    
}

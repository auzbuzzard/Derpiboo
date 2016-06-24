//
//  DBClientProfile.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/23/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

protocol DBClientProfileProtocol {
    var profileName: String? { get set }
    var profile: DBProfile? { get set }
    var usernameFromDefaults: String? { get set }
    func loadProfile(preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((profile: DBProfile?) -> Void)?)
    func loadProfile(profileName: String, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((profile: DBProfile?) -> Void)?)
}

class DBClientProfile: DBClient, DBClientProfileProtocol {
    
    //--- Data ---//
    
    var profileName: String?
    var profile: DBProfile?
    
    //--- Load profile ---//
    
    func loadProfile(preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((profile: DBProfile?) -> Void)?) {
        if let profileName = profileName {
            loadProfile(profileName, preloadAvatar: preloadAvatar, urlSession: urlSession,copyToClass: copyToClass, handler: handler)
        } else {
            print("DBClientProfile has not class var: profileName. Use overloaded loadProfile() with profileName param instead")
        }
    }
    
    func loadProfile(profileName: String, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((profile: DBProfile?) -> Void)?) {
        if profileName.containsString("Background+Pony+#") || profileName.containsString("Background Pony #"){ return }
        guard let url = assembleURL(profileName).toURL() else { print("loadProfile() error, url: \(assembleURL(profileName))"); return }
        
        NetworkManager.loadData(url, urlSession: urlSession ?? clientSession, completion: { data in
            do {
                if let dict = try self.parseJSON(data) {
                    self.dictToDBProfile(dictionary: dict, preloadAvatar: preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: handler)
                }
            } catch {
                print("Error at parseJSON(data:) for loadProfile() for url: \(url). JSONError:\n\(error)")
            }
        })
    }
    
    //--- URLs ---//
    
    private func assembleURL(profileName: String) -> String {
        var u = "https://www.derpibooru.org/"
        u.appendContentsOf("profiles/\(profileName).json")
        
        return u
    }
    
    //--- UserDefaults ---//
    
    var usernameFromDefaults: String? {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if let name = defaults.stringForKey("username") {
                return name
            } else {
                return nil
            }
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            
            if usernameFromDefaults == nil { defaults.removeObjectForKey("username") }
            else { defaults.setValue(usernameFromDefaults, forKey: "username") }
        }
    }

    
    //--- Creating Data from Json dictionaries ---//
    
    private func dictToDBProfile(dictionary result: NSDictionary, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: (DBProfile -> Void)?) {
        
        guard let id = result["id"] as? Int else { print("Error parsing id"); return }
        guard let name = result["name"] as? String else { print("Error parsing name"); return }
        guard let slug = result["slug"] as? String else { print("Error parsing slug"); return }
        guard let role = result["role"] as? String else { print("Error parsing role"); return }
        let description = result["description"] as? String// else { print("Error parsing description") }
        let avatar_url = result["avatar_url"] as? String// else { print("Error parsing avatar_url"); return }
        guard let created_at = result["created_at"] as? String else { print("Error parsing created_at"); return }
        
        guard let comment_count = result["comment_count"] as? Int else { print("Error parsing comment_count"); return }
        guard let uploads_count = result["uploads_count"] as? Int else { print("Error parsing uploads_count"); return }
        guard let post_count = result["post_count"] as? Int else { print("Error parsing post_count"); return }
        guard let topic_count = result["topic_count"] as? Int else { print("Error parsing topic_count"); return }
        
        guard let awards = result["awards"] as? [NSDictionary] else { print("Error parsing awards"); return }
        var profileAwards = [DBProfileAwards]()
        for award in awards {
            guard let image_url = award["image_url"] as? String else { print("Error parsing image_url"); continue }
            guard let title = award["title"] as? String else { print("Error parsing title"); continue }
            guard let id = award["id"] as? Int else { print("Error parsing award id"); continue }
            guard let awarded_on = award["awarded_on"] as? String else { print("Error parsing awarded_on"); continue }
            
            let dbProfileAwards = DBProfileAwards(image_url: image_url, title: title, id: id, awarded_on: awarded_on)
            profileAwards.append(dbProfileAwards)
        }
        
        let p = DBProfile(id: id, name: name, slug: slug, role: role, description: description, avatar_url: avatar_url, created_at: created_at, comment_count: comment_count, uploads_count: uploads_count, post_count: post_count, topic_count: topic_count, awards: profileAwards, avatar: nil)
        
        if preloadAvatar {
            p.downloadAvatar(urlSession, completion: nil)
        }
        
        if copyToClass {
            profile = p
        }
        
        if let handler = handler {
            handler(p)
        } else {
            profile = p
        }
    }
    
}

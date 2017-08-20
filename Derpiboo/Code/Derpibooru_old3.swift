//
//  Derpibooru.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/10/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

/*
 This is the proxy for the DBClients. Interact with this class only for talking to DB.
 */
//
//class Derpibooru /*: DBClientImagesProtocol, DBClientProfileProtocol, DBClientCommentsProtocol*/ {
//
//    enum DBResultType { case image, list, profile, comment }
//    
//    static func newDBImageResult() -> DBImageResult {
//        return DBImageResult()
//    }
//    

//    lazy private var clientImages = DBClientImages()
//    lazy private var clientProfile = DBClientProfile()
//    lazy private var clientComments = DBClientComments()
//    
//    //--- DBClientImagesProtocol --///
//    
//    var images: [DBImage] { get { return clientImages.images } }
//    var searchTerm: String { get { return clientImages.searchTerm } set { clientImages.searchTerm = newValue } }
//    
//    var listName: String! { get { return clientImages.listName } set { clientImages.listName = newValue } }
//    var mainList: [[Derpiboo.DBImage]] { get { return clientImages.mainList } }
//    
//    func getListNameReadable(listName: String?) -> String {
//        return clientImages.getListNameReadable(listName)
//    }
//    
//    func clearImages() {
//        clientImages.clearImages()
//    }
//    func loadImages(ofType resultsType: DBClientImages.ImageResultsType, asNewResults: Bool, preloadThumbImage: Bool, urlSession: NSURLSession?, copyToClass: Bool, completion: ((images: [DBImage]?) -> Void)?) {
//        clientImages.loadImages(ofType: resultsType, asNewResults: asNewResults, preloadThumbImage: preloadThumbImage, urlSession: urlSession, copyToClass: copyToClass, completion: completion)
//    }
//    func loadImages(ofType resultsType: DBClientImages.ImageResultsType, asNewResults: Bool, listName: String?, preloadThumbImage: Bool, urlSession: NSURLSession?, copyToClass: Bool, completion: ((images: [DBImage]?) -> Void)?) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.clientImages.loadImages(ofType: resultsType, asNewResults: asNewResults, listName: listName, preloadThumbImage: preloadThumbImage, urlSession: urlSession, copyToClass: copyToClass, completion: completion)
//        }
//    }
//    
//    func loadMainList(urlSession: NSURLSession?, copyToClass: Bool, completion: ((listNames: [[DBImage]]?) -> Void)?) {
//        clientImages.loadMainList(urlSession, copyToClass: copyToClass, completion: completion)
//    }
//    
//    //--- DBClientProfileProtocol ---//
//    
//    var profileName: String? { get { return clientProfile.profileName } set { clientProfile.profileName = profileName } }
//    var profile: DBProfile? { get { return clientProfile.profile } set { clientProfile.profile = profile } }
//    var usernameFromDefaults: String? { get { return clientProfile.usernameFromDefaults } set { clientProfile.usernameFromDefaults = usernameFromDefaults } }
//    
//    func loadProfile(preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((profile: DBProfile?) -> Void)?) {
//        clientProfile.loadProfile(preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: handler)
//    }
//    func loadProfile(profileName: String, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((profile: DBProfile?) -> Void)?) {
//        clientProfile.loadProfile(profileName, preloadAvatar: preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: handler)
//    }
//    
//    //--- DBClientCommentsProtocol ---//
//    
//    var comments: [DBComment] { get { return clientComments.comments } }
//    func clearComments() {
//        clientComments.clearComments()
//    }
//    func loadComments(image_id id: String, preloadProfile: Bool, preloadAvatar: Bool, urlSession: NSURLSession?, copyToClass: Bool, handler: ((comments: [DBComment]) -> Void)?) {
//        clientComments.loadComments(image_id: id, preloadProfile: preloadProfile, preloadAvatar: preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: handler)
//    }
}






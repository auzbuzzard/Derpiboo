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

class Derpibooru: DBClientImagesProtocol, DBClientProfileProtocol, DBClientCommentsProtocol {
    
    lazy fileprivate var clientImages = DBClientImages()
    lazy fileprivate var clientProfile = DBClientProfile()
    lazy fileprivate var clientComments = DBClientComments()
    
    //--- DBClientImagesProtocol --///
    
    var images: [DBImage] { get { return clientImages.images } }
    var searchTerm: String { get { return clientImages.searchTerm } set { clientImages.searchTerm = newValue } }
    
    var listName: String! { get { return clientImages.listName } set { clientImages.listName = newValue } }
    var mainList: [[Derpiboo.DBImage]] { get { return clientImages.mainList } }
    
    func getListNameReadable(_ listName: String?) -> String {
        return clientImages.getListNameReadable(listName)
    }
    
    func clearImages() {
        clientImages.clearImages()
    }
    func loadImages(ofType resultsType: DBClientImages.ImageResultsType, asNewResults: Bool, preloadThumbImage: Bool, urlSession: URLSession?, copyToClass: Bool, completion: ((_ images: [DBImage]?) -> Void)?) {
        clientImages.loadImages(ofType: resultsType, asNewResults: asNewResults, preloadThumbImage: preloadThumbImage, urlSession: urlSession, copyToClass: copyToClass, completion: completion)
    }
    func loadImages(ofType resultsType: DBClientImages.ImageResultsType, asNewResults: Bool, listName: String?, preloadThumbImage: Bool, urlSession: URLSession?, copyToClass: Bool, completion: ((_ images: [DBImage]?) -> Void)?) {
        DispatchQueue.main.async {
            self.clientImages.loadImages(ofType: resultsType, asNewResults: asNewResults, listName: listName, preloadThumbImage: preloadThumbImage, urlSession: urlSession, copyToClass: copyToClass, completion: completion)
        }
    }
    
    func loadMainList(_ urlSession: URLSession?, copyToClass: Bool, completion: ((_ listNames: [[DBImage]]?) -> Void)?) {
        clientImages.loadMainList(urlSession, copyToClass: copyToClass, completion: completion)
    }
    
    //--- DBClientProfileProtocol ---//
    
    var profileName: String? { get { return clientProfile.profileName } set { clientProfile.profileName = profileName } }
    var profile: DBProfile? { get { return clientProfile.profile } set { clientProfile.profile = profile } }
    var usernameFromDefaults: String? { get { return clientProfile.usernameFromDefaults } set { clientProfile.usernameFromDefaults = usernameFromDefaults } }
    
    func loadProfile(_ preloadAvatar: Bool, urlSession: URLSession?, copyToClass: Bool, handler: ((_ profile: DBProfile?) -> Void)?) {
        clientProfile.loadProfile(preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: handler)
    }
    func loadProfile(_ profileName: String, preloadAvatar: Bool, urlSession: URLSession?, copyToClass: Bool, handler: ((_ profile: DBProfile?) -> Void)?) {
        clientProfile.loadProfile(profileName, preloadAvatar: preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: handler)
    }
    
    //--- DBClientCommentsProtocol ---//
    
    var comments: [DBComment] { get { return clientComments.comments } }
    func clearComments() {
        clientComments.clearComments()
    }
    func loadComments(image_id id: String, preloadProfile: Bool, preloadAvatar: Bool, urlSession: URLSession?, copyToClass: Bool, handler: ((_ comments: [DBComment]) -> Void)?) {
        clientComments.loadComments(image_id: id, preloadProfile: preloadProfile, preloadAvatar: preloadAvatar, urlSession: urlSession, copyToClass: copyToClass, handler: handler)
    }
}









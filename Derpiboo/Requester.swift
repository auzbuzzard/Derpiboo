//
//  Server.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation

class Requester {
    static var base_url: String {
        get { return "https://derpibooru.org" }
    }
}

class ListRequester: Requester {
    typealias completion = (ListResult) -> Void
    
    enum ListType {
        case home, search, list(type: ListListType)//, watched, favorites, upvotes, uploaded
    }
    enum ListListType:String {
        case top_scoring
    }
    
    static var list_home_url: String { get { return base_url + "/images.json" } }
    static var list_search_url: String { get { return base_url + "/search.json" } }
    static var list_list_url: String { get { return base_url + "/lists.json" } }
    static func list_list_list_url(type: ListListType) -> String {
        return base_url + "/\(type.rawValue).json"
    }
    
    func get(listOfType listType: ListType, tags: String?, result: ListResult?, completion: @escaping completion) {
        var url = ""
        switch listType {
        case .home: url.append(ListRequester.list_home_url)
        case .search: url.append(ListRequester.list_search_url)
        case .list(let type): url.append(ListRequester.list_list_list_url(type: type))
        }
        
        var params = [String]()
        
        params.append("page=\(result?.page ?? 1)")
        
        if let tags = tags {
            params.append("q=\(tags)")
        }
        
        url.append("?\(params.joined(separator: "&"))")
        
        print(url)
        do {
            try Network.fetch(url: url, params: nil) {
                data in
                DispatchQueue.global().async {
                    do {
                        let r = result ?? ListResult()
                        try ListParser.parse(data: data, asType: listType, toResult: r)
                        completion(r)
                    } catch {
                        print(error)
                    }
                }
            }
        } catch {
            print("ListRequester Error \(error)")
        }
    }
    
}

class ImageRequester: Requester {
    typealias completion = (ImageResult) -> Void
    
    static var image_url: String { get { return base_url } }
    
    func get(imageOfId id: Int, completion: @escaping completion) {
        let url = ImageRequester.image_url + "/\(id).json"
        do {
            try Network.fetch(url: url, params: nil) { data in
                DispatchQueue.global().async {
                    do {
                        let result = try ImageParser.parse(data: data)
                        completion(result)
                    } catch {
                        print("ImageRequester get error")
                    }
                }
            }
        } catch {
            print("ImageRequester Error")
        }
    }
    
}

class UserRequester: Requester {
    typealias completion = (UserResult) -> Void
    
    static let user_url = base_url + "/user/index"
    static let user_show_url = base_url + "/user/show"
    
    func get(userOfId id: Int, completion: @escaping completion) {
        let url = UserRequester.user_show_url + "/\(id).json"
        do {
            try Network.fetch(url: url, params: nil) { data in
                DispatchQueue.global().async {
                    do {
                        let result = try UserParser.parse(data: data)
                        completion(result)
                    } catch {
                        print("UserRequester get error: \(data) of url: \(url)")
                    }
                }
            }
        } catch {
            print("UserRequester Error")
        }
    }
    
    func get(userOfId id: Int, searchCache: Bool, completion: @escaping completion) {
        if searchCache, let user = try? Cache.shared.getUser(id: id) {
            completion(user)
            return
        }
        
        get(userOfId: id, completion: completion)
        
    }
    
}

class PoolRequester: Requester {
    
}

class FilterRequester: Requester {
    
    typealias completion = (FilterResult) -> Void
    
    static var filter_url: String { get {
        return base_url + "/filters"
        } }
    
    func get(filterOfId id: Int, completion: @escaping completion) {
        let url = FilterRequester.filter_url + "/\(id).json"
        do {
            try Network.fetch(url: url, params: nil) { data in
                DispatchQueue.global().async {
//                    do {
//                        let result = try UserParser.parse(data: data)
//                        completion(result)
//                    } catch {
//                        print("UserRequester get error: \(data) of url: \(url)")
//                    }
                }
            }
        } catch {
            print("UserRequester Error")
        }
    }
    
}


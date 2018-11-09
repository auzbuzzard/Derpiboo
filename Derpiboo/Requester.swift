//
//  Server.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit
// import Fuzi

class Requester {
    static var base_url: String {
        return "https://derpibooru.org"
    }
}

class ImageRequester: Requester {
    static var image_url: String { return base_url }
    
    func getUrl(for id: Int, withJson: Bool = true) -> String {
        return ImageRequester.image_url + "/\(id)\(withJson ? "" : ".json")"
    }
    func downloadImageResult(for id: Int) -> Promise<ImageResult> {
        let url = getUrl(for: id)
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<ImageResult> in
            return ImageParser.parse(data: data)
        }
    }
    
}

class TagRequester: Requester {
    static var tag_url: String { return base_url + "/tags" }
    
    func downloadTag(for id: Int) -> Promise<TagResult> {
        let url = TagRequester.tag_url + "/\(id).json"
        
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data in
            TagParser.parse(data: data)
            }.then { result -> Promise<TagResult> in
                Cache.tag.setTag(result).then { result }
            }.then { result -> Promise<TagResult> in
                return Promise<TagResult>(value: result)
        }
    }
    @available(*, unavailable, message: "DB don't have a way to return tag search in json yet.")
    func searchTag(searchTerm: String) -> Promise<TagResult> {
        let url = TagRequester.tag_url + "?tq=\(searchTerm).json"
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<TagResult> in
            return TagParser.parse(data: data)
        }
    }
}

class CommentRequester: Requester {
    func downloadComments(for id: String) -> Promise<[CommentResult]> {
        let url = ImageRequester.image_url + "/\(id).json?comments=''"
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<[CommentResult]> in
            return CommentParser.parse(data: data)
        }
    }
}


class UserRequester: Requester {
    func getUser(bySlug slug: String) -> Promise<UserResult> {
        let url = Requester.base_url + "/profiles/\(slug).json"
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<UserResult> in
            return UserParser.parse(data: data)
        }
    }
}

class FilterListRequester: Requester {
    func downloadLists() -> Promise<FilterListResult> {
        let url = Requester.base_url + "/filters.json"
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<FilterListResult> in
            return FilterListParser.parse(data: data)
        }
    }
}

class FilterRequester: Requester {
    func downloadFilter(id: Int) -> Promise<FilterResult> {
        let url = Requester.base_url + "/filters/\(id).json"
        return Network.get(url: url).then(on: .global(qos: .userInitiated)) { data -> Promise<FilterResult> in
            return FilterParser.parse(data: data)
        }
    }
}







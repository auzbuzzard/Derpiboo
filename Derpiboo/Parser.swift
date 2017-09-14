//
//  Parser.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

protocol Parser {
    associatedtype ParseResult: Result
    static func parse(data: Data) -> Promise<ParseResult>
}

protocol ParserForList {
    associatedtype ParseResult: Result
    static func parse(data: Data, as listType: ListRequester.ListType) -> Promise<ParseResult>
}

protocol ParserForItem {
    associatedtype Result: ResultItem
    static func parse(dictionary item: NSDictionary) -> Promise<Result>
}

enum ParserError: Error {
    case JsonDataCorrupted(data: Data)
    case CannotCastJsonIntoNSDictionary(data: Data)
}

class ListParser: ParserForList {
    static func parse(data: Data, as listType: ListRequester.ListType) -> Promise<ListResult> {
        return Promise { fulfill, reject in
            do {
                let key: String = {
                    switch listType {
                    case .images, .lists: return "images"
                    case .search: return "search"
                    }
                }()
                
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary, let items = json[key] as? Array<NSDictionary> else { reject(ParserError.CannotCastJsonIntoNSDictionary(data: data)); return }
                
                var results = [ImageResult]()
                
                for item in items {
                    ImageParser.parse(dictionary: item).then { result -> Void in
                        results.append(result)
                        }.catch { error -> Void in
                            
                    }
                }
                fulfill(ListResult(result: results))
            } catch {
                reject(error)
            }
        }
    }
}



class UserParser: Parser {
    
    static func parse(data: Data) -> Promise<UserResult> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    parse(dictionary: json).then { result -> Void in
                        fulfill(result)
                        }.catch { error in
                            reject(error)
                    }
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            } catch {
                reject(error)
            }
        }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<UserResult> {
        let id = item["id"] as? Int ?? 0
        let name = item["name"] as? String ?? ""
        let slug = item["slug"] as? String ?? ""
        let role = item["role"] as? String ?? ""
        let description = item["description"] as? String
        let avatar_url = item["avatar_url"] as? String
        let created_at = item["created_at"] as? String ?? ""
        let comment_count = item["comment_count"] as? Int ?? 0
        let uploads_count = item["uploads_count"] as? Int ?? 0
        let post_count = item["post_count"] as? Int ?? 0
        let topic_count = item["topic_count"] as? Int ?? 0
        
        let links: [Any] = []
        let awards: [UserResult.MetadataAwards] = {
            var array = [UserResult.MetadataAwards]()
            if let json = item["awards"] as? Array<NSDictionary> {
                for awardItem in json {
                    let image_url = awardItem["image_url"] as? String ?? ""
                    let title = awardItem["title"] as? String ?? ""
                    let id = awardItem["id"] as? Int ?? 0
                    let label = awardItem["label"] as? String ?? ""
                    let awarded_on = awardItem["awarded_on"] as? String ?? ""
                    
                    let metadataAwards = UserResult.MetadataAwards(image_url: image_url, title: title, id: id, label: label, awarded_on: awarded_on)
                    
                    array.append(metadataAwards)
                }
            }
            return array
        }()
        
        let metadata = UserResult.Metadata(id: id, name: name, slug: slug, role: role, description: description, avatar_url: avatar_url, created_at: created_at, comment_count: comment_count, uploads_count: uploads_count, post_count: post_count, topic_count: topic_count, links: links, awards: awards)
        
        return Promise { fulfill, _ in
            fulfill(UserResult(metadata: metadata))
        }
    }
}

class TagParser: Parser, ParserForItem {
    static func parse(data: Data) -> Promise<TagResult> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary, let tag = json["tag"] as? NSDictionary {
                    parse(dictionary: tag).then { result -> Void in
                        fulfill(result)
                        }.catch { error in
                            reject(error)
                    }
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            }
        }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<TagResult> {
        let id = item["id"] as? String ?? ""
        let name = item["name"] as? String ?? ""
        let slug = item["slug"] as? String ?? ""
        let description = item["description"] as? String ?? ""
        let short_description = item["short_description"] as? String ?? ""
        let images = item["images"] as? Int ?? 0
        let spoiler_image_uri = item["spoiler_image_uri"] as? String
        let aliased_to = item["aliased_to"] as? String
        let aliased_to_id = item["aliased_to_id"] as? String
        let namespace = item["namespace"] as? String
        let name_in_namespace = item["name_in_namespace"] as? String
        let implied_tags = item["implied_tags"] as? String
        let implied_tag_ids = item["implied_tag_ids"] as? [Int]
        let category = item["category"] as? String
        
        let metadata = TagResult.Metadata(id: id, name: name, slug: slug, description: description, short_description: short_description, images: images, spoiler_image_uri: spoiler_image_uri, aliased_to: aliased_to, aliased_to_id: aliased_to_id, namespace: namespace, name_in_namespace: name_in_namespace, implied_tags: implied_tags, implied_tag_ids: implied_tag_ids, category: category)
        
        return Promise { fulfill, _ in
            fulfill(TagResult(metadata: metadata))
        }
    }
}

class CommentParser {
    static func parse(data: Data) -> Promise<[CommentResult]> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary, let comments = json["comments"] as? Array<NSDictionary> {
                    var results = [CommentResult]()
                    
                    for comment in comments {
                        parse(dictionary: comment).then { result -> Void in
                            results.append(result)
                            }.catch { error -> Void in
                                
                        }
                    }
                    fulfill(results)
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            }
        }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<CommentResult> {
        let id = item["id"] as? Int ?? 0
        let body = item["body"] as? String ?? ""
        let author = item["author"] as? String ?? ""
        let image_id = item["image_id"] as? Int ?? 0
        let posted_at = item["posted_at"] as? String ?? ""
        let deleted = item["deleted"] as? Bool ?? false
        
        let metadata = CommentResult.Metadata(id: id, body: body, author: author, image_id: image_id, posted_at: posted_at, deleted: deleted)
        
        return Promise { fulfill, _ in
            fulfill(CommentResult(metadata: metadata))
        }
    }
}

class FilterListParser: Parser {
    
    static func parse(data: Data) -> Promise<FilterListResult> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    var system_filters = [FilterResult]()
                    var user_filters: [FilterResult]?
                    var search_filters = [FilterResult]()
                    
                    if let system_filters_json = json["system_filters"] as? Array<NSDictionary> {
                        for item in system_filters_json {
                            FilterParser.parse(dictionary: item).then { result in
                                system_filters.append(result)
                                }.catch { error in print(error) }
                        }
                    }
                    if let user_filters_json = json["user_filters"] as? Array<NSDictionary> {
                        user_filters = [FilterResult]()
                        for item in user_filters_json {
                            FilterParser.parse(dictionary: item).then { result in
                                user_filters!.append(result)
                                }.catch { error in print(error) }
                        }
                    }
                    if let search_filters_json = json["search_filters"] as? Array<NSDictionary> {
                        for item in search_filters_json {
                            FilterParser.parse(dictionary: item).then { result in
                                search_filters.append(result)
                                }.catch { error in print(error) }
                        }
                    }
                    
                    fulfill(FilterListResult(system_filters: system_filters, user_filters: user_filters, search_filters: search_filters))
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            }
        }
    }
    
}

class FilterParser: Parser {
    
    static func parse(data: Data) -> Promise<FilterResult> {
        return Promise { fulfill, reject in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? NSDictionary {
                    parse(dictionary: json).then { result -> Void in
                        fulfill(result)
                        }.catch { error in
                            reject(error)
                    }
                } else {
                    reject(ParserError.CannotCastJsonIntoNSDictionary(data: data))
                }
            }
        }
    }
    
    static func parse(dictionary item: NSDictionary) -> Promise<FilterResult> {
        let id = item["id"] as? Int ?? 0
        let name = item["name"] as? String ?? ""
        let description = item["description"] as? String ?? ""
        let hidden_tag_ids = item["hidden_tag_ids"] as? [Int] ?? [Int]()
        let spoilered_tag_ids = item["spoilered_tag_ids"] as? [Int] ?? [Int]()
        let spoilered_tags = item["spoilered_tags"] as? String ?? ""
        let hidden_tags = item["hidden_tags"] as? String ?? ""
        let hidden_complex = item["hidden_complex"] as? String ?? ""
        let spoilered_complex = item["spoilered_complex"] as? String ?? ""
        let `public` = item["public"] as? Bool ?? false
        let system = item["system"] as? Bool ?? false
        let user_count = item["user_count"] as? Int ?? 0
        let user_id = item["user_id"] as? Int
        
        let metadata = FilterResult.Metadata(id: id, name: name, description: description, hidden_tag_ids: hidden_tag_ids, spoilered_tag_ids: spoilered_tag_ids, spoilered_tags: spoilered_tags, hidden_tags: hidden_tags, hidden_complex: hidden_complex, spoilered_complex: spoilered_complex, public: `public`, system: system, user_count: user_count, user_id: user_id)
        
        return Promise { fulfill, _ in
            fulfill(FilterResult(metadata: metadata))
        }
    }
    
}






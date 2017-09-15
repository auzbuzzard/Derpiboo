//
//  ListRequester.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/13/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

class ListRequester: Requester {
    enum ListType {
        case images, lists, search
    }
    
    enum SortType: Int {
        case creationDate = 0, score, wilsonScore, relevance, width, height, comments, random
        
        static let count = 8
        
        var queryString: String {
            switch self {
            case .creationDate: return "created_at"
            case .score: return "score"
            case .wilsonScore: return "wilson"
            case .relevance: return "relevance"
            case .width: return "width"
            case .height: return "height"
            case .comments: return "comments"
            case .random: return "random"
            }
        }
        var description: String {
            switch self {
            case .creationDate: return "Creation Date"
            case .score: return "Score"
            case .wilsonScore: return "Wilson Score"
            case .relevance: return "Relevance"
            case .width: return "Width"
            case .height: return "Height"
            case .comments: return "Comments"
            case .random: return "Random!"
            }
        }
    }
    
    enum SortOrderType {
        case descending, ascending
        
        var queryString: String {
            switch self {
            case .descending: return "desc"
            case .ascending: return "asc"
            }
        }
    }
    
    static func url(for type: ListType) -> String {
        switch type {
        case .images: return base_url + "/images.json"
        case .lists: return base_url + "/lists.json"
        case .search: return base_url + "/search.json"
        }
    }
    
    func downloadList(for type: ListType, tags: [String]?, withSorting sortFilter: SortFilter?, page: Int?) -> Promise<ListResult> {
        var params = [String]()
        
        if let page = page {
            params.append("page=\(page)")
        }
        
        if let tags = tags {
            params.append("q=\(tags.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!)")
        }
        
        if let sortFilter = sortFilter {
            params.append("sf=\(sortFilter.sortBy.queryString)")
            params.append("sd=\(sortFilter.sortOrder.queryString)")
        }
        
        params.append("filter_id=\(FilterManager.main.currentFilterID)")
        
        let url = ListRequester.url(for: type) + "?\(params.joined(separator: "&"))"
        
        #if DEBUG
            print("ListRequester downloading list: \(url)")
        #endif
        
        let network = Network.get(url: url)
        
        return network.then(on: .global(qos: .userInitiated)) { data -> Promise<ListResult> in
            return ListParser.parse(data: data, as: type)
        }
    }
    
}

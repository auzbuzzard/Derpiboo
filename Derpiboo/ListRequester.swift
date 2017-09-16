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

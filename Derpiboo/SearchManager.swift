//
//  SearchManager.swift
//  e926
//
//  Created by Austin Chau on 10/10/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation

struct SortFilter {
    let sortBy: ListRequester.SortType
    let sortOrder: ListRequester.SortOrderType
}

class SearchManager {
    
    static let main = SearchManager()
    
    private static let defaultsKey = "SearchHistory"
    private let concurrentQueue = DispatchQueue(label: "searchManager.concurrentQueue", attributes: .concurrent)
    
    private init() {
        if let storedHistory = UserDefaults.standard.array(forKey: SearchManager.defaultsKey) as? [String] {
            searches = storedHistory.map { SearchHistory(timeStamp: Date(), searchString: $0, sortFilter: SortFilter(sortBy: .creationDate, sortOrder: .descending)) }
        }
    }
    
    private(set) lazy var searches = [SearchHistory]()
    
    func recentSearches(count: Int) -> [SearchHistory] {
        var array = [SearchHistory]()
        for i in 0..<(min(count, searches.count)) {
            array.append(searches[searches.count - 1 - i])
        }
        return array
    }
    
    func appendSearch(_ search: SearchHistory) {
        searches = searches.filter { $0.searchString != search.searchString }
        
        searches.append(search)
        updateDefaults()
    }
    
    func clearHistory() {
        searches.removeAll()
        updateDefaults()
    }
    
    private func updateDefaults() {
        
        UserDefaults.standard.set(searches.map { $0.searchString }, forKey: SearchManager.defaultsKey)
        UserDefaults.standard.synchronize()
    }
    
    @objc(SearchManager_SearchHistory) class SearchHistory: NSObject, NSCoding {
        func encode(with aCoder: NSCoder) {
            aCoder.encode(timeStamp, forKey: "timeStamp")
            aCoder.encode(searchString, forKey: "searchString")
            aCoder.encode(sortFilter, forKey: "sortFilter")
        }
        
        required convenience init?(coder aDecoder: NSCoder) {
            guard let timeStamp = aDecoder.decodeObject(forKey: "timeStamp") as? Date,
                let searchString = aDecoder.decodeObject(forKey: "searchString") as? String,
                let sortFilter = aDecoder.decodeObject(forKey: "sortFilter") as? SortFilter else { return nil }
            
            self.init(timeStamp: timeStamp, searchString: searchString, sortFilter: sortFilter)
        }
        
        let timeStamp: Date
        let searchString: String
        let sortFilter: SortFilter
        
        init(timeStamp: Date, searchString: String, sortFilter: SortFilter) {
            self.timeStamp = timeStamp
            self.searchString = searchString
            self.sortFilter = sortFilter
        }
        
    }
}






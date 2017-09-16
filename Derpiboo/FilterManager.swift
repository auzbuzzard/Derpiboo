//
//  FilterManager.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/14/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

class FilterManager {
    
    static let currentFilterDidChangeName = "derpiboo.currentFilterDidChangeName"
    static let filtersDidSet = "derpiboo.filtersDidSet"
    
    static let storedFilterID = "selectedFilterID"
    static let defaultFilterID = 100073
    static let auzbuzzardFilterID = 144017
    
    static let main = FilterManager()
    
    private init() {
        _ = reloadListResult()
        currentFilterID = storedSelectedFilterID() ?? FilterManager.auzbuzzardFilterID
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private var filterListResult: FilterListResult?
    
    var filters = Dictionary<FilterListType, [FilterResult]>() {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(FilterManager.filtersDidSet), object: nil)
        }
    }
    
    
    var currentFilterID: Int = 0 {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(FilterManager.currentFilterDidChangeName), object: nil)
        }
    }
    
    var currentFilter: FilterResult? {
        return filter(from: currentFilterID)
    }
    
    enum FilterListType { case system_filters, user_filters, search_filters, special }
    
    // Internal Methods
    
    func reloadListResult() -> Promise<Void> {
        return FilterListRequester().downloadLists().then { listResult -> Void in
            self.filterListResult = listResult
            self.filters[FilterListType.system_filters] = listResult.system_filters
            self.filters[FilterListType.user_filters] = listResult.user_filters
            self.filters[FilterListType.search_filters] = listResult.search_filters
            self.reloadSpecialFilters()
            }.catch { error in print(error) }
    }
    
    fileprivate func reloadSpecialFilters() {
        FilterRequester().downloadFilter(id: FilterManager.auzbuzzardFilterID).then { result in
            self.filters[FilterListType.special] = [result]
            }.catch { error in print(error) }
    }
    
    func filter(from id: Int) -> FilterResult? {
        return filters.values.joined().first(where: {$0.id == id} )
    }
    
    func storedSelectedFilterID() -> Int? {
        return UserDefaults.standard.integer(forKey: FilterManager.storedFilterID) != 0 ? UserDefaults.standard.integer(forKey: FilterManager.storedFilterID) : nil
    }
    
    func storeSelectedFilterID(_ id: Int) {
        UserDefaults.standard.set(id, forKey: FilterManager.storedFilterID)
    }
}

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
    static let storedFilterID = "selectedFilterID"
    static let defaultFilterID = 100073
    static let auzbuzzardFilterID = 144017
    
    static let main = FilterManager()
    
    private init() {
        filterListResult = FilterListRequester().downloadLists()
        loadFilterFromStoredID()
    }
    
    var filterListResult: Promise<FilterListResult>
    
    var currentFilter: FilterResult? {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(FilterManager.currentFilterDidChangeName), object: nil)
        }
    }
    
    func reloadListResult() {
        filterListResult = FilterListRequester().downloadLists()
    }
    
    func storedSelectedFilterID() -> Int? {
        return UserDefaults.standard.integer(forKey: FilterManager.storedFilterID) != 0 ? UserDefaults.standard.integer(forKey: FilterManager.storedFilterID) : nil
    }
    
    func storeSelectedFilterID(_ id: Int) {
        UserDefaults.standard.set(id, forKey: FilterManager.storedFilterID)
    }
    
    func loadFilterFromStoredID() {
        FilterRequester().downloadFilter(id: storedSelectedFilterID() ?? FilterManager.auzbuzzardFilterID).then { result in
            self.currentFilter = result
            }.catch { error in print(error) }
    }
}

//
//  Filters.swift
//  Derpiboo
//
//  Created by Austin Chau on 10/19/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation

class Filters {
    static let shared = Filters()
    private init() { }
    
    lazy var result = FilterListResult()
    
    var currentFilter: FilterResult?
    
    func getCurrentFilter() {
        
    }
}

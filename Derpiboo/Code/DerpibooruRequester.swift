//
//  DerpibooruRequester.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/16/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation

class DerpibooruRequester {
    
    
}

class DerpibooruListRequester: DerpibooruRequester {
    
    typealias result = DerpibooruListResult
    typealias completion = ((_ result: result) -> Void)?
    
    var listName: String?
    
    var searchTerm: String?
    
    func newRequest(listName: String?, searchTerm: String?, result: result?, completion: completion) {
        self.listName = listName
        self.searchTerm = searchTerm
        request(result: result, completion: completion)
    }
    
    func request(result: result?, completion: completion) {
        if let urlRequest = try? NetworkManager.clientURLRequest(generateURLPath()) {
            NetworkManager.get(urlRequest, completion: { success, data in
                if success {
                    if let data = data {
                        if result != nil {
                            
                        }
                    }
                }
            })
        }
    }
    
    private func generateURLPath() -> String {
        var u = "/"
        if listName == nil {
            u.append(searchTerm == nil ? "images.json":"search.json")
        } else {
            u.append("lists/\(listName).json")
        }
        return u
    }
    
}

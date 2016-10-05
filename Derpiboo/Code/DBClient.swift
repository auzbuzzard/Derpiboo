//
//  DBClient.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/23/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class DBClient {
    
    //--- Useful stuffs and enums ---//
    
    let clientSession = URLSession(configuration: URLSessionConfiguration.default)
    

    enum ResultsType: String {
        case Home = "images", Search = "search", List = "lists", Profile = "profiles", Comments = "comments"
    }
    
    //--- Parsing Json ---//
    
    func parseJSON(_ data: Data) throws -> NSDictionary? {
        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
    }
    
    //--- UserDefaults ---//
    
    func getUserAPIKey() -> String? {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "userAPIKeySwitch") {
            guard let api = defaults.string(forKey: "userAPIKey") else { return nil }
            return api
        } else {
            return nil
        }
    }
    
}

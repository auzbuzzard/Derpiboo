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
    
    let clientSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    

    enum ResultsType: String {
        case Home = "images", Search = "search", List = "lists", Profile = "profiles", Comments = "comments"
    }
    
    //--- Parsing Json ---//
    
    func parseJSON(data: NSData) throws -> NSDictionary? {
        return try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
    }
    
    //--- UserDefaults ---//
    
    func getUserAPIKey() -> String? {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if defaults.boolForKey("userAPIKeySwitch") {
            guard let api = defaults.stringForKey("userAPIKey") else { return nil }
            return api
        } else {
            return nil
        }
    }
    
}

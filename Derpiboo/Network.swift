//
//  Network.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case InvalidURL(url: String)
    
    func string() -> String {
        switch self {
        case .InvalidURL(let u):
            return "Network Error: Invalid URL (url: \(u))"
        }
    }
}

class Network {
    
    typealias completionData = (Data) -> Void
//    
//    static func get(url: String, completion: @escaping completionData) throws {
//        do {
//            try post(url: url, params: nil, completion: completion)
//        } catch let error {
//            throw error
//        }
//    }
    
    static func fetch(url: String, params: Dictionary<String, String>?, completion: @escaping (Data) -> Void) throws {
        guard let u = URL(string: url) else { throw NetworkError.InvalidURL(url: url) }
        let session = URLSession.shared
        
        var request = URLRequest(url: u)
        if params == nil {
            request.httpMethod = "GET"
        } else {
            request.httpMethod = "POST"
            
//            var paramsString = ""
//            for (key, value) in params! {
//                let scapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
//                let scapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
//                paramsString += "\(scapedKey)=\(scapedValue)&"
//            }
//            paramsString.remove(at: paramsString.index(before: paramsString.endIndex))
//            
//            request.httpBody = paramsString.data(using: String.Encoding.utf8)
            if let params = params {
                for (key, value) in params {
                    request.addValue(value, forHTTPHeaderField: key)
                }
            }
            
        }
        //request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        //print(request.httpBody)
        
        
        let task = session.dataTask(with: request, completionHandler: {
            (
            data, response, error) in
            
            //print("data: \(data)\n, response: \(response)\n, error: \(error)")
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                print("Network.fetch error")
                return
            }
            
//            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
//            print(dataString)
            
            completion(data!)
            
        })
        
        task.resume()
    }
}

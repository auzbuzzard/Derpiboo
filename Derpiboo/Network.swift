//
//  Network.swift
//  E621
//
//  Created by Austin Chau on 10/6/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

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
    
    static func get(url: String, session: URLSession? = nil) -> Promise<Data> {
        return post(url: url, params: nil, session: session)
    }
    
    static func post(url: String, params: [String]?, session: URLSession? = nil) -> Promise<Data> {
        return Promise { fulfill, reject in
            guard let u = URL(string: url) else { reject(NetworkError.InvalidURL(url: url)); return }
            let session = session ?? URLSession.shared
            
            let request = NSMutableURLRequest(url: u)
            if params == nil {
                request.httpMethod = "GET"
            } else {
                request.httpMethod = "POST"
                
                if let paramString = params?.joined(separator: "&") {
                    request.httpBody = paramString.data(using: String.Encoding.utf8)
                }
            }
            
            let userAgent: String = {
                let bundleIdentifier = Bundle.main.bundleIdentifier ?? "BundleIdentifier"
                let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "BundleVersion"
                return "\(bundleIdentifier)/\(bundleVersion) (by auzbuzzard on e621)"
            }()
            
            request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
            #if DEBUG
                //print(u)
            #endif
            let dataPromise: URLDataPromise = session.dataTask(with: request as URLRequest)
            dataPromise.asDataAndResponse().then { (data, respone) -> Void in
                fulfill(data)
                }.catch(execute: reject)
        }
    }
    
    static func getWithAlamo(url: String) -> DataRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.get.rawValue
        return Alamofire.request(request as URLRequestConvertible)
    }
    
    static func postWithAlamo(url: String, params: [String:String]?, encoding: ParameterEncoding) -> DataRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = HTTPMethod.post.rawValue
        request.allHTTPHeaderFields = params ?? nil
        return Alamofire.request(request as URLRequestConvertible)
    }
}

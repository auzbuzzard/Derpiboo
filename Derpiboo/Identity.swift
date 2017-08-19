//
//  Identity.swift
//  E621
//
//  Created by Austin Chau on 10/8/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import Foundation

class Identity {
    
    static let main = Identity()
    private init() { }
    
    var authToken: String = ""
    
    var isLoggedIn: Bool {
        get {
            return user != nil
        }
    }
    
    var user: UserResult?
    /*
    func signIn(user: String, password: String, remember_me: Bool) {
        let url = Requester.base_url + "/users/sign_in"
        do {
            try Network.fetch(url: url, params: nil, completion: { data in
                if let html = String(data: data, encoding: .utf8) {
                    //print("HTML: \(html)")
                    let s = html.range(of: "<meta name=\"csrf-token\" content=\"")
                    let sub = html.substring(from: s!.upperBound)
                    let sub2 = sub.substring(to: html.index(html.startIndex, offsetBy: 88))
                    self.authToken = sub2
                    
                    var form = Dictionary<String, String>()
                    form["utf8"] = "✓"
                    form["authenticity_token"] = self.authToken
                    form["user[email]"] = user
                    form["user[password]"] = password
                    form["user[remember_me]"] = remember_me ? "1" : "0"
                    form["commit"] = "Sign in"
                    
                    print("signing in")
                    
                    do {
                        try Network.fetch(url: url, params: form, completion: { data in
                            
                            print("login in\n\n\n\n")
                            print(String(data: data, encoding: .utf8))
                            //                try? Network.fetch(url: "https://derpibooru.org/users/edit", params: nil, completion: { data in
                            //                    print("getting api\n\n\n\n")
                            //                    print(String(data: data, encoding: .utf8))
                            //                })
                        })
                    } catch {
                        print("bad error")
                    }

                }
            })
        } catch {
            
        }
        
        
 
    }*/
    
}

//
//  ListCollectionVCTest.swift
//  DerpibooTests
//
//  Created by Austin Chau on 9/15/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import XCTest
@testable import Derpiboo

class ListCollectionVCTest: XCTestCase {
    
    var listVC: ListCollectionVC!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "ListCollection",
                                      bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "listCollectionVC") as! ListCollectionVC
        UIApplication.shared.keyWindow!.rootViewController = vc
        let _ = vc.view
        listVC = vc
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testExample() {
        ListRequester().downloadList(for: .images, tags: nil, withSorting: nil, page: nil).then { result in
            print(result.results.count)
        }
        listVC.getNewResult()
    }
    
    func testPerformanceExample() {
        self.measure {
            
        }
    }
    
}

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
        vc.dataSource = ListCollectionVM(result: ListResult())
        UIApplication.shared.keyWindow!.rootViewController = vc
        let _ = vc.view
        listVC = vc
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testDownloadCountEqual() {
        let exp1 = expectation(description: "testDownloadCountEqual")
        
        var downloadCount = 1
        var vcCount = 0
        _ = ListRequester().downloadList(for: .images, tags: nil, withSorting: nil, page: nil).then { result -> Void in
            downloadCount = result.results.count
            self.listVC.getNewResult()
            vcCount = self.listVC.collectionView!.numberOfItems(inSection: 0)
            
            XCTAssertEqual(downloadCount, vcCount)
            exp1.fulfill()
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error { XCTFail("Timeout: \(error)") }
        }
    }
    
    func testAvgDBImageListFirstPageCount() {
        
        let exp1 = expectation(description: "testDownloadCountEqual")
        
        var downloadCount = [Int]()
        let max = 10
        
        for n in 0..<max {
            _ = ListRequester().downloadList(for: .images, tags: nil, withSorting: nil, page: nil).then { result -> Void in
                downloadCount.append(result.results.count)
                if n == max - 1 {
                    XCTAssert(downloadCount.count == max, "\(downloadCount)")
                    exp1.fulfill()
                }
            }
        }
        
        waitForExpectations(timeout: 300) { (error) in
            if let error = error { XCTFail("Timeout: \(error)") }
        }
        
    }
    
    func testDownloadSpeed() {
        let exp1 = expectation(description: "testDownloadSpeed")

        self.measure {
            _ = ListRequester().downloadList(for: .images, tags: nil, withSorting: nil, page: nil).then { result in
                exp1.fulfill()
            }
        }
        
        waitForExpectations(timeout: 10) { (error) in
            if let error = error { XCTFail("Timeout: \(error)") }
        }
    }
    
}

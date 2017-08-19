//
//  ListCollectionVM.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/16/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import Foundation
import PromiseKit

class ListCollectionVM: ListCollectionVCDataSource {
    // Mark: - Internal Data
    
    private var result: ListResult
    
    init(result: ListResult) {
        self.result = result
    }
    
    // Mark: - Interface
    
    var results: [ImageResult] { return result.results }
    
    var tags: [String]? { return result.tags }
    
    func getResults(asNew reset: Bool, withTags tags: [String]?) -> Promise<Void> {
        if reset { result = ListResult() }
        result.tags = tags
        return ListRequester().downloadList(for: tags != nil ? .search : .images, tags: tags, page: result.currentPage + 1).then { listResult -> Void in
            self.result.add(listResult)
        }.catch { error in
            print("Error getting results: \(error)")
        }
    }
    
    // Mark: - Methods
    
    func tags(from stringTag: String?) -> [String]? {
        return stringTag?.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespaces)}
    }
}

struct ListCollectionVCMainCellVM: ListCollectionVCMainCellDataSource {
    
    // Mark: - Internal Data
    
    private let result: ImageResult
    
    init(result: ImageResult) {
        self.result = result
    }
    
    // Mark: - Interface
    
    var artistsName: String { return result.metadata.uploader }
    var uploaderName: String { return result.metadata.uploader }
    var favCount: Int { return result.metadata.faves }
    var upvote: Int { return result.metadata.upvotes }
    var downvote: Int { return result.metadata.downvotes }
    var score: Int { return result.metadata.score }
    //var rating: ImageResult.Metadata.Ratings { return result.metadata.rating }
    var imageType: ImageResult.Metadata.File_Ext { return result.metadata.original_format_enum! }
    var mainImage: Promise<UIImage> { return result.image(ofSize: .large)}
    var profileImage: Promise<UIImage> { return result.image(ofSize: .thumb)}
}

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
    
    var sortBy: ListRequester.SortType = .creationDate
    var sortOrder: ListRequester.SortOrderType = .descending
    
    
    func getResults(asNew reset: Bool, withTags tags: [String]?, withSorting: (sortBy: ListRequester.SortType, inOrder: ListRequester.SortOrderType)?) -> Promise<Void> {
        if reset { result = ListResult() }
        result.tags = tags
        if let withSorting = withSorting {
            sortBy = withSorting.sortBy
            sortOrder = withSorting.inOrder
        }
        return ListRequester().downloadList(for: tags != nil ? .search : .images, tags: tags, withSorting: withSorting != nil ? (sortBy: sortBy, inOrder: sortOrder) : nil, page: result.currentPage + 1).then { listResult -> Void in
            self.result.add(listResult)
        }.catch { error in
            print("Error getting results: \(error)")
        }
    }
    
    func setSorting(sortBy: ListRequester.SortType, sortOrder: ListRequester.SortOrderType) {
        self.sortBy = sortBy
        self.sortOrder = sortOrder
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
    var fileType: ImageResult.Metadata.File_Ext? { return result.metadata.original_format_enum }
    
    var artistsName: String { return result.metadata.uploader }
    var uploaderName: String { return result.metadata.uploader }
    var favCount: Int { return result.metadata.faves }
    var upvote: Int { return result.metadata.upvotes }
    var downvote: Int { return result.metadata.downvotes }
    var score: Int { return result.metadata.score }
    //var rating: ImageResult.Metadata.Ratings { return result.metadata.rating }
    var imageType: ImageResult.Metadata.File_Ext { return result.metadata.original_format_enum ?? .jpg }
    var mainImageData: Promise<Data> { return result.imageData(forSize: .large)}
    var profileImageData: Promise<Data> { return result.imageData(forSize: .thumb)}
}

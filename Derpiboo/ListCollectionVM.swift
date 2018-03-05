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
    
    // MARK: - Internal Data
    
    private var result: ListResult
    
    init(result: ListResult, sortFilter: SortFilter? = nil) {
        self.result = result
        if let sortFilter = sortFilter {
            self.sortFilter = sortFilter
        }
    }
    
    // MARK: - Interface
    
    var results: [ImageResult] { return result.results }
    
    var tags: [String]? { return result.tags }
    
    var sortFilter: SortFilter = SortFilter(sortBy: .creationDate, sortOrder: .descending)
    
    // TODO: - Fix loading next page so that it can detect fails.
    func getResults(asNew reset: Bool, withTags tags: [String]?, withSorting: SortFilter?) -> Promise<Void> {
        if reset { result = ListResult() }
        result.tags = tags
        if let withSorting = withSorting {
            sortFilter = withSorting
        }
        return ListRequester().downloadList(for: tags != nil ? .search : .images, tags: tags, withSorting: sortFilter, page: result.currentPage + 1).then { listResult -> Void in
            self.result.add(listResult)
        }
    }
    
    func setSorting(filter: SortFilter) {
        self.sortFilter = filter
    }
    
    // MARK: - Methods
    
    func tags(from stringTag: String?) -> [String]? {
        return stringTag?.components(separatedBy: ",").map{ $0.trimmingCharacters(in: .whitespaces)}
    }
}

struct ListCollectionVCMainCellVM: ListCollectionVCMainCellDataSource {
    
    // MARK: - Internal Data
    
    private let result: ImageResult
    
    init(result: ImageResult) {
        self.result = result
    }
    
    // MARK: - Interface
    var fileType: ImageResult.Metadata.File_Ext? { return result.metadata.original_format_enum }
    
    var artistsName: String { return result.metadata.uploader }
    var uploaderName: String { return result.metadata.uploader }
    var favCount: Int { return result.metadata.faves }
    var upvote: Int { return result.metadata.upvotes }
    var downvote: Int { return result.metadata.downvotes }
    var score: Int { return result.metadata.score }
    //var rating: ImageResult.Metadata.Ratings { return result.metadata.rating }
    var imageType: ImageResult.Metadata.File_Ext { return result.metadata.original_format_enum ?? .jpg }
    var mainImageData: Promise<Data> { return result.imageData(for: .large)}
    var profileImageData: Promise<Data> { return result.imageData(for: .thumb)}
}

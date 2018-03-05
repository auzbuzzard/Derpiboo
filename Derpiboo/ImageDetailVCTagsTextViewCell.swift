//
//  ImageDetailVCTagsTextViewCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/31/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit

class ImageDetailVCTagsTextViewCell: UITableViewCell {
    
    static let storyboardID = "imageDetailVCTagsTextViewCell"
    
    @IBOutlet weak var textView: UITextView!
    
    func setupLayout() {
        
    }
    
    func setupContent(imageResult: ImageResult) {
        
    }
    
    // Mark: - Private methods
    
    private func setTagsAsAttributedString(tags: [String]) -> NSAttributedString {
        when(fulfilled: tags.map { TagRequester().downloadTag(for: Int($0) ?? 0) } ).then { results -> Void in
            //let attributeStrings = results.map { self.attributedString(from: $0) }
            }.catch { error in print(error) }
        return NSAttributedString()
    }
    
    private func attributedString(from tagResult: TagResult) -> NSAttributedString {
        return NSAttributedString(string: tagResult.metadata.name, attributes: [
            NSFontAttributeName: UIFont.systemFont(ofSize: 16)
            ])
    }
}






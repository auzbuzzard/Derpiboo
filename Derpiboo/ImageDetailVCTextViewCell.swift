//
//  ImageDetailVCTextViewCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/30/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit

class ImageDetailVCTextViewCell: UITableViewCell {
    
    static let storyboardID = "imageDetailVCTextViewCell"
    
    @IBOutlet weak var textView: UITextView!
    
    func setupLayout() {
        
    }
    
    func setupContent(dataSource: ImageResult) {
        textView.attributedText = attributedString(from: dataSource.metadata.description)
        textView.sizeToFit()
    }
    
    private func attributedString(from string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [
            NSForegroundColorAttributeName : Theme.colors().labelText
            ])
    }

}

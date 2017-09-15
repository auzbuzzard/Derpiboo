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
    
    
    
    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    func setupLayout() {
        
        //BkgdView
        bkgdView.backgroundColor = Theme.colors().background2
        
        bkgdView.layer.cornerRadius = 10
        bkgdView.layer.masksToBounds = true
    }
    
    func setupContent(dataSource: ImageResult) {
        textView.attributedText = attributedString(from: dataSource.metadata.description)
        textView.sizeToFit()
    }
    
    private func attributedString(from string: String) -> NSAttributedString {
        return NSAttributedString(string: string, attributes: [
            NSForegroundColorAttributeName: Theme.colors().labelText,
            NSFontAttributeName: UIFont.systemFont(ofSize: 17)
            ])
    }

}

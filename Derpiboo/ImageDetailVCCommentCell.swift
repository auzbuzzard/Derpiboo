//
//  ImageDetailVCCommentCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/30/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit

class ImageDetailVCCommentCell: UITableViewCell {
    
    static let storyboardID = "imageDetailVCCommentCell"

    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mainTextView: UITextView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
    }
    
    func setupLayout() {
        //BkgdView
        bkgdView.backgroundColor = Theme.colors().background2
        
        bkgdView.layer.cornerRadius = 10
        bkgdView.layer.masksToBounds = true
        
        mainTextView.textColor = Theme.colors().labelText
    }
    
    func setupContent(comment: CommentResult?) {
        guard let comment = comment else { return }
        profileImageView.image = #imageLiteral(resourceName: "no_avatar")
        headerLabel.text = comment.metadata.author
        mainTextView.text = comment.metadata.body
    }
}

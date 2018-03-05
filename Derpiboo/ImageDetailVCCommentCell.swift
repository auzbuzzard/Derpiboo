//
//  ImageDetailVCCommentCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/30/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit

class ImageDetailVCCommentCell: UITableViewCell {
    
    static let storyboardID = "imageDetailVCCommentCell"
    
    var currentIndexPath: IndexPath!

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
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.layer.masksToBounds = true
        
        mainTextView.textColor = Theme.colors().labelText
    }
    
    func setupContent(comment: CommentResult?, indexPath: IndexPath) {
        currentIndexPath = indexPath
        guard let comment = comment else { return }
        if let slug = comment.metadata.author.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) {
            UserResult.getUser(by: slug).then { user -> Promise<Void> in
                guard let imageUrl = user.metadata.avatar_url else { return Promise(error: CommentCellError.noImageURL) }
                #if DEBUG
                    print("[Verbose] Comment has avatar. Getting it now.")
                #endif
                return Cache.image.getImageData(for: imageUrl, size: .full)
                .recover { error -> Promise<Data> in
                    #if DEBUG
                        print("[Verbose] No comment avatar in cache.")
                    #endif
                    return Network.get(url: "https:\(imageUrl)")
                    }
                .then { imageData -> Void in
                    #if DEBUG
                        print("[Verbose] Setting Comment Avatar.")
                    #endif
                    _ = Cache.image.setImageData(imageData, id: imageUrl, size: .full)
                    if let image = UIImage(data: imageData), indexPath == self.currentIndexPath {
                        self.profileImageView.image = image
                    }
                }
            }.catch { error in
                self.profileImageView.image = #imageLiteral(resourceName: "no_avatar")
                if case CommentCellError.noImageURL = error {
                    //self.profileImageView.image = #imageLiteral(resourceName: "no_avatar")
                } else { print(error) }
            }
        }
        headerLabel.text = comment.metadata.author
        mainTextView.text = comment.metadata.body
    }
    
    enum CommentCellError: Error {
        case noImageURL
    }
}

//
//  ListCollectionVCMainCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/16/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit

protocol ListCollectionVCMainCellDataSource {
    var artistsName: String { get }
    var uploaderName: String { get }
    var favCount: Int { get }
    var upvote: Int { get }
    var downvote: Int { get }
    var score: Int { get }
    //var rating: ImageResult.Metadata.Ratings { get }
    var imageType: ImageResult.Metadata.File_Ext { get }
    var mainImage: Promise<UIImage> { get }
    var profileImage: Promise<UIImage> { get }
}

class ListCollectionVCMainCell: UICollectionViewCell {
    static let storyboardID = "mainCell"
    
    var currentIndexPath: IndexPath!
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var titleSubheading: UILabel!
    
    @IBOutlet weak var mainImage: UIImageView!
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var footerUpvoteLabel: UILabel!
    @IBOutlet weak var footerDownvoteLabel: UILabel!
    @IBOutlet weak var footerFavLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImage.image = nil
    }
    
    func setupImageViewGesture(receiver: ListCollectionVC) {
        let singleTap = UITapGestureRecognizer(target: receiver, action: #selector(receiver.segue(isTappedBy:)))
        singleTap.numberOfTapsRequired = 1
        mainImage.addGestureRecognizer(singleTap)
        mainImage.isUserInteractionEnabled = true
    }
    
    // Mark: - Actual filling in the data and layout
    
    func setupCellLayout(windowWidth: CGFloat) {
        //        contentView.layer.cornerRadius = bounds.size.width < windowWidth ? 10 : 10
        //        contentView.layer.masksToBounds = true
        //
        //        layer.shadowColor = UIColor.black.cgColor
        //        layer.backgroundColor = UIColor.clear.cgColor
        //        layer.shadowOpacity = 0.25
        //        layer.shadowOffset = CGSize.zero
        //        layer.shadowRadius = 5
        //        layer.masksToBounds = false
        //        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        
    }
    
    func setCellContents(indexPath: IndexPath, dataSource: ListCollectionVCMainCellDataSource) {
        currentIndexPath = indexPath
        
        titleView.backgroundColor = Theme.colors().background2
        footerView.backgroundColor = Theme.colors().background2
        titleLabel.text = "\(dataSource.artistsName)"
        titleSubheading.text = "\(dataSource.uploaderName)"
        footerFavLabel.text = "\(dataSource.favCount)"
        footerUpvoteLabel.text = "\(dataSource.upvote)"
        footerDownvoteLabel.text = "\(dataSource.downvote)"
        titleLabel.textColor = .white
        titleLabel.sizeToFit()
        //titleLabelBkgdView.layer.masksToBounds = true
        //titleLabelBkgdView.layer.cornerRadius = titleLabelBkgdView.frame.size.height / 2
        //titleLabelBkgdView.layer.backgroundColor = ratingColor.cgColor
        
        setMainImage(indexPath: indexPath, dataSource: dataSource)
    }
    
    func setMainImage(indexPath: IndexPath, dataSource: ListCollectionVCMainCellDataSource) {
        _ = dataSource.mainImage.then { image -> Void in
            if indexPath == self.currentIndexPath {
                self.mainImage.image = image
            }
        }
    }
    
}

//
//  ListCollectionVCMainCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/16/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit
import Gifu

protocol ListCollectionVCMainCellDataSource {
    var fileType: ImageResult.Metadata.File_Ext? { get }
    
    var artistsName: String { get }
    var uploaderName: String { get }
    var favCount: Int { get }
    var upvote: Int { get }
    var downvote: Int { get }
    var score: Int { get }
    //var rating: ImageResult.Metadata.Ratings { get }
    var imageType: ImageResult.Metadata.File_Ext { get }
    var mainImageData: Promise<Data> { get }
    var profileImageData: Promise<Data> { get }
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
    
    lazy var label = UILabel()
    lazy var fileTypeWarningView = UIImageView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.removeFromSuperview()
        fileTypeWarningView.removeFromSuperview()
        mainImage.image = nil
        mainImage.prepareForReuse()
        titleImage.image = nil
    }
    
    func setupImageViewGesture(receiver: ListCollectionVC) {
        let singleTap = UITapGestureRecognizer(target: receiver, action: #selector(receiver.segue(isTappedBy:)))
        singleTap.numberOfTapsRequired = 1
        mainImage.addGestureRecognizer(singleTap)
        mainImage.isUserInteractionEnabled = true
    }
    
    // Mark: - Actual filling in the data and layout
    
    func setupCellLayout(windowWidth: CGFloat) {
        titleImage.layer.cornerRadius = 5
        titleImage.layer.masksToBounds = true
        
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
        
        //check if image is unhandled filetype
        if dataSource.fileType == .webm || dataSource.fileType == .swf {
            fileTypeWarningView.image = dataSource.fileType == .webm ? #imageLiteral(resourceName: "webm") : #imageLiteral(resourceName: "swf")
            contentView.addSubview(fileTypeWarningView)
            fileTypeWarningView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraints([
                NSLayoutConstraint(item: fileTypeWarningView, attribute: .centerX, relatedBy: .equal, toItem: mainImage, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: fileTypeWarningView, attribute: .centerY, relatedBy: .equal, toItem: mainImage, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: fileTypeWarningView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: mainImage.bounds.width * 0.3),
                NSLayoutConstraint(item: fileTypeWarningView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: mainImage.bounds.width * 0.3)
                ])
            //webmIconView.bounds.size = CGSize(width: mainImage.bounds.width * 0.3, height: mainImage.bounds.width * 0.3)

            /*
            label.text = "webm"
            label.textColor = Theme.colors().labelText
            label.sizeToFit()
            contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraints([
                    NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: mainImage, attribute: .centerX, multiplier: 1, constant: 0),
                    NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: mainImage, attribute: .centerY, multiplier: 1, constant: 0)
                ])
             */
        }
        
        setMainImage(indexPath: indexPath, dataSource: dataSource)
        titleImage.image = #imageLiteral(resourceName: "no_avatar")
    }
    
    func setMainImage(indexPath: IndexPath, dataSource: ListCollectionVCMainCellDataSource) {
        _ = dataSource.mainImageData.then { data -> Void in
            if indexPath == self.currentIndexPath {
                if dataSource.imageType == .gif {
                    self.mainImage.animate(withGIFData: data)
                } else {
                    guard let image = UIImage(data: data) else { print("Image at \(indexPath) could not be casted into UIImage."); return }
                    self.mainImage.image = image
                }
            }
        }
    }
    
}







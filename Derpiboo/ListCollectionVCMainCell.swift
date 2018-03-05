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
    enum Errors: Error {
        case imageTypeNotSupported(indexPath: IndexPath)
    }
    
    static let storyboardID = "mainCell"
    
    var currentIndexPath: IndexPath!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelBkgdView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    
    lazy var label = UILabel()
    lazy var fileTypeWarningView = UIImageView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.removeFromSuperview()
        fileTypeWarningView.removeFromSuperview()
        mainImageView.stopAnimatingGIF()
        mainImageView.image = nil
        mainImageView.prepareForReuse()
    }
    
    func setupImageViewGesture(receiver: ListCollectionVC) {
        let singleTap = UITapGestureRecognizer(target: receiver, action: #selector(receiver.segue(isTappedBy:)))
        singleTap.numberOfTapsRequired = 1
        mainImageView.addGestureRecognizer(singleTap)
        mainImageView.isUserInteractionEnabled = true
    }
    
    // Mark: - Actual filling in the data and layout
    
    func setupCellLayout(windowWidth: CGFloat) {
        
        contentView.backgroundColor = Theme.colors().background2
        
        contentView.layer.cornerRadius = bounds.size.width < windowWidth ? 10 : 10
        contentView.layer.masksToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.backgroundColor = UIColor.clear.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        
        titleLabel.textColor = Theme.colors().labelText
        titleLabelBkgdView.layer.masksToBounds = true
        titleLabelBkgdView.layer.cornerRadius = titleLabelBkgdView.frame.size.height / 2
        titleLabelBkgdView.layer.backgroundColor = Theme.colors().background2.withAlphaComponent(0.75).cgColor
    }
    
    func setCellContents(indexPath: IndexPath, dataSource: ListCollectionVCMainCellDataSource) {
        currentIndexPath = indexPath
        
        let titleString = NSMutableAttributedString()
        titleString.append(NSAttributedString(string: "⬆︎\(dataSource.upvote)", attributes: [NSForegroundColorAttributeName: Theme.colors().upv]))
        titleString.append(NSAttributedString(string: " | ", attributes: [NSForegroundColorAttributeName: UIColor.clear]))
        titleString.append(NSAttributedString(string: "⬇︎\(dataSource.downvote)", attributes: [NSForegroundColorAttributeName: Theme.colors().dnv]))
        titleString.append(NSAttributedString(string: " | ", attributes: [NSForegroundColorAttributeName: UIColor.clear]))
        titleString.append(NSAttributedString(string: "♥︎\(dataSource.favCount)", attributes: [NSForegroundColorAttributeName: Theme.colors().fav]))
        titleLabel.attributedText = titleString
        
        //titleLabel.text = "⬆︎\(dataSource.upvote) | ⬇︎\(dataSource.downvote) | ♥︎\(dataSource.favCount)"
        titleLabel.sizeToFit()
        
        //check if image is unhandled filetype
        if dataSource.fileType == .webm || dataSource.fileType == .swf {
            setFileTypeWarningImage(dataSource)
        }
        
        setMainImage(indexPath: indexPath, dataSource: dataSource)
    }
    
    func setMainImage(indexPath: IndexPath, dataSource: ListCollectionVCMainCellDataSource) {
        dataSource.mainImageData.then { data -> Void in
            if indexPath == self.currentIndexPath {
                if dataSource.imageType == .gif {
                    self.mainImageView.prepareForAnimation(withGIFData: data)
                    self.mainImageView.startAnimatingGIF()
                } else {
                    guard let image = UIImage(data: data) else { throw  Errors.imageTypeNotSupported(indexPath: indexPath) }
                    self.mainImageView.image = image
                }
            }
        }.catch { error in
            switch error {
            case ImageResult.Errors.imageTypeNotSupported(_), Errors.imageTypeNotSupported(_):
                break
            default: print(error)
            }
        }
    }
    
    func animateImage() {
        self.mainImageView.startAnimatingGIF()
    }
    
    // Internal methods
    
    
    fileprivate func setFileTypeWarningImage(_ dataSource: ListCollectionVCMainCellDataSource) {
        fileTypeWarningView.image = dataSource.fileType == .webm ? #imageLiteral(resourceName: "webm") : #imageLiteral(resourceName: "swf")
        contentView.addSubview(fileTypeWarningView)
        fileTypeWarningView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addConstraints([
            NSLayoutConstraint(item: fileTypeWarningView, attribute: .centerX, relatedBy: .equal, toItem: mainImageView, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: fileTypeWarningView, attribute: .centerY, relatedBy: .equal, toItem: mainImageView, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: fileTypeWarningView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: mainImageView.bounds.width * 0.3),
            NSLayoutConstraint(item: fileTypeWarningView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: mainImageView.bounds.width * 0.3)
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
    
}







//
//  ImageDetailVCTagTableCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/19/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit
import DGCollectionViewLeftAlignFlowLayout

class ImageDetailVCTagTableCell: UITableViewCell {
    static let storyboardID = "imageDetailVCTagTableCell"
    
    // Mark: - Properties
    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    weak var tableView: UITableView?
    
    func setupLayout(tableView: UITableView) {
        self.tableView = tableView
        
        collectionView.backgroundColor = UIColor.clear
        
        //BkgdView
        bkgdView.backgroundColor = Theme.colors().background2
        
        bkgdView.layer.cornerRadius = 10
        bkgdView.layer.masksToBounds = true
    }
    
    // Mark: - Methods
    func setCollectionViewDataSourceDelegate(_ delegate: UICollectionViewDelegate & UICollectionViewDataSource, forRow row: Int) {
        collectionView.delegate = delegate
        collectionView.dataSource = delegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        //collectionView.frame = CGRect(x: 0, y: 0, width: targetSize.width, height: CGFloat(MAXFLOAT))
        //collectionView.layoutIfNeeded()
        let layoutSize = collectionView.collectionViewLayout.collectionViewContentSize
        
        return CGSize(width: layoutSize.width + 48, height: layoutSize.height + 32)
    }
    
    
}





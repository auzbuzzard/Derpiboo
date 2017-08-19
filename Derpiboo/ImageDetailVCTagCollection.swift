//
//  ImageDetailVCTagCollection.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/19/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit
import DGCollectionViewLeftAlignFlowLayout

/// Class that defines the collectionview cell within the tag section of the ImageDetailVC
class ImageDetailVCTagCollectionCell: UICollectionViewCell {
    static let storyboardID = "imageDetailVCTagCollectionCell"
    
    @IBOutlet weak var label: UILabel!
    
    func setupCellContents(tag: String, result: ImageResult, onComplete: @escaping () -> Void) {
        label.text = tag
        label.backgroundColor = Theme.colors().highlight2
        self.label.sizeToFit()
        contentView.setNeedsLayout()
        onComplete()
        
    }
    func setupCellLayout() {
        contentView.layer.cornerRadius = bounds.size.height / 2
        contentView.layer.masksToBounds = true
    }
}


// MARK: - Extension to ImageDetailVC that allows it to control the collectionview
extension ImageDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageResult.metadata.tag_ids.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageDetailVCTagCollectionCell.storyboardID, for: indexPath) as! ImageDetailVCTagCollectionCell
        
        let tags = imageResult.metadata.tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        cell.setupCellLayout()
        cell.setupCellContents(tag: tags[indexPath.row], result: imageResult) {
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tag = imageResult.metadata.tags.components(separatedBy: ",")[indexPath.row].trimmingCharacters(in: .whitespaces)
        #if DEBUG
            print("Tag tapped: \(tag)")
        #endif
        open(with: tag)
    }
}

// MARK: - Extension to ImageDetailVC That controls the layout of the collectionview
extension ImageDetailVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeLabel = UILabel()
        sizeLabel.text = imageResult.metadata.tags.components(separatedBy: ",")[indexPath.row]
        sizeLabel.sizeToFit()
        
        return CGSize(width: sizeLabel.bounds.width + 16, height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension DGCollectionViewLeftAlignFlowLayout {
    
}





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

fileprivate let useTagId = false

/// Class that defines the collectionview cell within the tag section of the ImageDetailVC
class ImageDetailVCTagCollectionCell: UICollectionViewCell {
    static let storyboardID = "imageDetailVCTagCollectionCell"
    
    @IBOutlet weak var label: UILabel!
    
    func setupCellContents(tag: TagResult) {
        label.text = tag.metadata.name
        label.backgroundColor = Theme.colors().highlight2
        self.label.sizeToFit()
        contentView.layoutIfNeeded()
    }
    func setupCellContents(tag: String, tagResult: TagResult? = nil) {
        label.text = tag
        label.backgroundColor =  Theme.colors().highlight2
        self.label.sizeToFit()
        contentView.layoutIfNeeded()
    }
    func setupCellLayout() {
        contentView.layer.cornerRadius = bounds.size.height / 2
        contentView.layer.masksToBounds = true
    }
}


// MARK: - Extension to ImageDetailVC that allows it to control the collectionview
extension ImageDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return useTagId ? imageResult.metadata.tag_ids.count : imageResult.metadata.tags.components(separatedBy: ",").count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageDetailVCTagCollectionCell.storyboardID, for: indexPath) as! ImageDetailVCTagCollectionCell
        
        if useTagId {
            guard  indexPath.row < imageResult.metadata.tag_ids.count else { return cell }
            let tagId = imageResult.metadata.tag_ids[indexPath.row]
            TagResult.getTag(for: tagId).then { result -> Void in
                //print("got result for \(result.metadata.name)")
                cell.setupCellLayout()
                cell.setupCellContents(tag: result)
                }.catch { error in print(error) }
        } else {
            let tags = imageResult.metadata.tags.components(separatedBy: ",")
            guard indexPath.row < tags.count else { return cell }
            cell.setupCellLayout()
            cell.setupCellContents(tag: tags[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if useTagId {
            guard imageResult.metadata.tag_ids.count < indexPath.row else { return }
            let tagId = imageResult.metadata.tag_ids[indexPath.row]
            TagResult.getTag(for: tagId).then { result -> Void in
                #if DEBUG
                    print("Tag tapped: \(result.metadata.name)")
                #endif
                self.open(with: result.metadata.slug)
                }.catch { error in print(error) }
        } else {
            let tags = imageResult.metadata.tags.components(separatedBy: ",")
            guard indexPath.row < tags.count else { return }
            #if DEBUG
                print("Tag tapped: \(tags[indexPath.row])")
            #endif
            self.open(with: tags[indexPath.row].trimmingCharacters(in: .whitespaces))
        }
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

/*
extension DGCollectionViewLeftAlignFlowLayout {
    public override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = (
            newBounds.width != collectionView?.bounds.width ||
                newBounds.height != collectionView?.bounds.height
        )
        return context
    }
}
*/


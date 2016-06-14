//
//  ImageGridVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/11/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageGridVC: UICollectionViewController {
    
    private let cellReuseIdentifier = "gridCell"
    
    var derpibooru: Derpibooru!
    var images: [DBImage] { get { return derpibooru.images } }
    
    var refreshControl: UIRefreshControl!
    
    let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
        collectionView?.backgroundColor = Utils.ColorDark.background
        
        pullToRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc private func pullToRefresh() {
        derpibooru.loadNewImages() {
            error in
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshControl.endRefreshing()
                self.collectionView?.reloadData()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return derpibooru.images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ImageGridCellVC
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        cell.backgroundColor = Utils.ColorDark.background2
        
        if let dbImage = dbImageFromIndexPath(indexPath) {
            //cell.favLabel.text = "\(dbImage.faves ?? 0)"
            //cell.scoreLabel.text = "\(dbImage.score ?? 0)"
            //cell.commentLabel.text = "\(dbImage.comment_count ?? 0)"
            
            if let image = dbImage.getImage(DBImage.ImageSizeType.thumb, urlSession: urlSession, completion: onImageDownloadComplete
                
//                dbImage, error in
//                dispatch_async(dispatch_get_main_queue()) {
////                    guard let indexPath = self.indexPathFromDBImage(dbImage) else { return }
////                    for vcell in (self.collectionView?.visibleCells())! {
////                        if self.collectionView?.indexPathForCell(vcell) == indexPath {
////                            self.collectionView?.reloadItemsAtIndexPaths([indexPath])
////                            //cell.cellImageView.image = dbImage.thumbImage
////                            break
////                        }
////                    }
            
//                }
            
                
            ) {
                cell.cellImageView.image = image
            }
        }
        
        return cell
    }
    
    func onImageDownloadComplete(dbImage: DBImage, error: ErrorType?) {
        dispatch_async(dispatch_get_main_queue()) {
            if error != nil { print(error); return }
            guard let indexPath = self.indexPathFromDBImage(dbImage) else { return }
            
            for cell in (self.collectionView?.visibleCells())! {
                if self.collectionView?.indexPathForCell(cell) == indexPath {
                    self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                    return
                }
            }
        }
        
    }
    
    //Convenience
    
    func indexPathToImageIndex(indexPath: NSIndexPath) -> Int? {
        if indexPath.row < images.count {
            return indexPath.row
        } else {
            return nil
        }
    }
    
    func imageIndexToIndexPath(index: Int) -> NSIndexPath {
        return NSIndexPath(forItem: index, inSection: 0)
    }
    
    func dbImageFromIndexPath(indexPath: NSIndexPath) -> DBImage? {
        guard let index = indexPathToImageIndex(indexPath) else { return nil }
        return images[index]
    }
    
    func indexPathFromDBImage(dbImage: DBImage) -> NSIndexPath? {
        guard let index = images.indexOf({$0 === dbImage}) else { return nil }
        return imageIndexToIndexPath(index)
    }
    
    
    //FlowLayout
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }

}

extension ImageGridVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let collectionWidth = CGRectGetWidth(collectionView.bounds)
        
        let targetSizeMax: CGFloat = UI_USER_INTERFACE_IDIOM() == .Pad ? 160 : 120
        
        var rowSize: CGFloat = 1
        while collectionWidth / rowSize > targetSizeMax {
            rowSize += 1
        }
        
        let itemWidth = collectionWidth / (rowSize - 1)
        
        return CGSizeMake(itemWidth - 2, itemWidth + 20)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
}

class ImageGridCellVC: UICollectionViewCell {
    
    @IBOutlet weak var favLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.image = nil
    }
    
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
}
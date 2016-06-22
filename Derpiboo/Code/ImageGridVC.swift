//
//  ImageGridVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/11/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageGridVC: UICollectionViewController {
    
    //--- TableViewRID ---//
    
    private let cellReuseIdentifier = "gridCell"
    private let footerReuseIdentifier = "gridFooter"
    
    //--- Data and Objects ---//
    
    var derpibooru: Derpibooru!
    var images: [DBImage] { get { return derpibooru.images } }
    
    var refreshControl: UIRefreshControl!
    
    let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    //--- Useful Properties ---//
    
    var isLoadingImages: Bool = false {
        didSet {
            shouldLoadMoreImage = !isLoadingImages
        }
    }
    var shouldLoadMoreImage: Bool = false
    
    //--- View Cycles ---//

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tabBarOriginalFrame = tabBarController?.tabBar.frame

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), forControlEvents: .ValueChanged)
        collectionView?.addSubview(refreshControl)
        collectionView?.backgroundColor = Utils.color().background
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.hidesBarsOnSwipe = true
        
    }
    
    //--- Loading Images ---//
    
    func loadNewImages() {
        pullToRefresh()
    }
    
    @objc private func pullToRefresh() {
        isLoadingImages = true
        derpibooru.loadNewImages() {
            error in
            dispatch_async(dispatch_get_main_queue()) {
                self.isLoadingImages = false
                self.refreshControl.endRefreshing()
                self.collectionView?.reloadData()
            }
        }
    }
    
    private func loadMoreImages(completion: (error: ErrorType?, isEndOfResults: Bool) -> Void) {
        isLoadingImages = true
        let currentImagesCount = images.count
        derpibooru.loadMoreImages() {
            error in
            self.isLoadingImages = false
            if let error = error { completion(error: error, isEndOfResults: false); return }
            let bool = currentImagesCount == self.images.count
            dispatch_async(dispatch_get_main_queue()) {
                completion(error: nil, isEndOfResults: bool)
                self.collectionView?.reloadData()
            }
        }
    }

    
    //--- Segues ---//

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImageDetail" {
            guard let indexPath = collectionView?.indexPathsForSelectedItems()?[0] else { return }
            guard let index = indexPathToImageIndex(indexPath) else { return }
            
            let vc = segue.destinationViewController as! ImageDetailPageVC
            
            vc.derpibooru = derpibooru
            vc.imageIndexFromSegue = index
            
            vc.hidesBottomBarWhenPushed = true
        }
    }
    

    //--- UICollectionViewDataSource ---//
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return derpibooru.images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ImageGridCell
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = Utils.color().background2.CGColor
        
        cell.backgroundColor = Utils.color().background
        cell.stackViewBackgroundView.backgroundColor = Utils.color().background2
        
        cell.favIcon.textColor = Utils.color().fav
        cell.favLabel.textColor = Utils.color().fav
        cell.upvIcon.textColor = Utils.color().upv
        cell.scoreLabel.textColor = Utils.color().labelText
        cell.dnvIcon.textColor = Utils.color().dnv
        cell.commentIcon.textColor = Utils.color().comment
        cell.commentLabel.textColor = Utils.color().comment
        
        if let dbImage = dbImageFromIndexPath(indexPath) {
            cell.favLabel.text = "\(dbImage.faves ?? 0)"
            cell.scoreLabel.text = "\(dbImage.score ?? 0)"
            cell.commentLabel.text = "\(dbImage.comment_count ?? 0)"
            
            if let image = dbImage.getImage(DBImage.ImageSizeType.thumb, urlSession: urlSession, completion: onImageDownloadComplete) {
                cell.cellImageView.image = image
            }
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: footerReuseIdentifier, forIndexPath: indexPath) as! ImageGridFooter
        
        footer.footerLabel.textColor = Utils.color().labelText
        footer.footerLabel.text = isLoadingImages == true ? "Loading" : images.count == 0 ? "" : "Loading More"
        
        if shouldLoadMoreImage {
            loadMoreImages() {
                error, isEndOfResults in
                if error == nil {
                    if isEndOfResults {
                        footer.footerLabel.text = "End of Results"
                    }
                }
            }
        }
        
        return footer
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
    
    //--- Convenience Methods ---//
    
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
    
    func clearImageGrid() {
        derpibooru.clearImages()
        collectionView?.reloadData()
    }
    
    
    //--- Orientation Change ---//
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    //--- ScrollView ---//
    
    var tabBarOriginalFrame: CGRect!

//    override func scrollViewDidScroll(scrollView: UIScrollView) {
//        print("toolbarHidden: \(navigationController?.toolbarHidden), hideBarOnSwipe: \(navigationController?.hidesBarsOnSwipe), hidesBottomBarWhenPushed: \(hidesBottomBarWhenPushed)")
//        
//        
//        var yOffset = scrollView.contentOffset.y
//        let yPanGesture = scrollView.panGestureRecognizer.translationInView(view).y
//        
//        guard let tabBar = tabBarController?.tabBar else { return }
//        
//        let tabBarHeight = tabBar.frame.size.height
//        
//        let tabBarOriginY = tabBar.frame.origin.y
//        let frameHeight = view.frame.size.height
//        
//        if yOffset >= tabBarHeight {
//            yOffset = tabBarHeight
//        }
//        
//        //up
//        if yPanGesture >= 0 && yPanGesture < tabBarHeight && tabBarOriginY > frameHeight - tabBarHeight {
//            yOffset = tabBarHeight - fabs(yPanGesture)
//        } else if yPanGesture >= 0 && yPanGesture < tabBarHeight && tabBarOriginY <= frameHeight - tabBarHeight {
//            yOffset = 0
//        }
//            //down
//        else if yPanGesture < 0 && tabBarOriginY < frameHeight {
//            yOffset = fabs(yPanGesture)
//        } else if yPanGesture < 0 && tabBarOriginY >= frameHeight {
//            yOffset = tabBarHeight
//        } else {
//            yOffset = 0
//        }
//        
//        if yOffset > 0 {
//            tabBar.frame = CGRect(x: tabBar.frame.origin.x, y: tabBarOriginalFrame.origin.y + yOffset, width: tabBar.frame.size.width, height: tabBar.frame.size.height)
//        } else if yOffset <= 0 {
//            tabBar.frame = self.tabBarOriginalFrame
//        }
//
//    }
    
//    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        if scrollView.panGestureRecognizer.translationInView(view).y >= 0 {
//            navigationController?.toolbarHidden = true
//        }
//    }

}

extension ImageGridVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //target rows: iPAD: 4 or 6, iPhone 3 or 5

        let collectionWidth = collectionView.bounds.width
        var itemWidth: CGFloat = 60
        let orientation = UIApplication.sharedApplication().statusBarOrientation
        if UI_USER_INTERFACE_IDIOM() == .Pad {
            itemWidth = orientation == .Portrait ? collectionWidth / 4 : collectionWidth / 6
        } else if UI_USER_INTERFACE_IDIOM() == .Phone {
            itemWidth = orientation == .Portrait ? collectionWidth / 3 : collectionWidth / 5
        }
        
        return CGSize(width: itemWidth - 2, height: itemWidth + 20)
        
//        let collectionWidth = CGRectGetWidth(collectionView.bounds)
//        
//        let targetSizeMax: CGFloat = UI_USER_INTERFACE_IDIOM() == .Pad ? 160 : 120
//        
//        var rowSize: CGFloat = 1
//        while collectionWidth / rowSize > targetSizeMax {
//            rowSize += 1
//        }
//        
//        let itemWidth = collectionWidth / (rowSize - 1)
//        
//        return CGSizeMake(itemWidth - 2, itemWidth + 20)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 2
    }
    
}

class ImageGridCell: UICollectionViewCell {
    
    @IBOutlet weak var stackViewBackgroundView: UIView!
    @IBOutlet weak var favIcon: UILabel!
    @IBOutlet weak var favLabel: UILabel!
    @IBOutlet weak var upvIcon: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dnvIcon: UILabel!
    @IBOutlet weak var commentIcon: UILabel!
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

class ImageGridFooter: UICollectionReusableView {
    
    @IBOutlet weak var footerLabel: UILabel!
    
}
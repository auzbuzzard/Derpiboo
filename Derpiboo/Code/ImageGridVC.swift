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
    
    fileprivate let cellReuseIdentifier = "gridCell"
    fileprivate let footerReuseIdentifier = "gridFooter"
    
    //--- Data and Objects ---//
    
    var derpibooru: Derpibooru!
    var images: [DBImage] { get { return derpibooru.images } }
    
    var imageResultsType: DBClientImages.ImageResultsType!
    var listName: String?
    
    var refreshControl: UIRefreshControl!
    
    let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    
    //--- Class Vars for Methods ---//
    
    let preloadThumbImage = true
    
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
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
        collectionView?.backgroundColor = Theme.current().background
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //navigationController?.hidesBarsOnSwipe = true
        
    }
    
    //--- Loading Images ---//
    
    func loadNewImages() {
        pullToRefresh()
    }
    
    @objc fileprivate func pullToRefresh() {
        isLoadingImages = true
        derpibooru.loadImages(ofType: imageResultsType, asNewResults: true, listName: listName, preloadThumbImage: true, urlSession: urlSession, copyToClass: true, completion: { _ in
            DispatchQueue.main.async {
                self.isLoadingImages = false
                self.refreshControl.endRefreshing()
                self.collectionView?.reloadData()
            }
        })
    }
    
    fileprivate func loadMoreImages(_ completion: @escaping (_ isEndOfResults: Bool) -> Void) {
        isLoadingImages = true
        let currentImagesCount = images.count
        derpibooru.loadImages(ofType: imageResultsType, asNewResults: false, listName: listName, preloadThumbImage: true, urlSession: urlSession, copyToClass: true, completion: { _ in
            let bool = currentImagesCount == self.images.count
            DispatchQueue.main.async {
                self.isLoadingImages = false
                completion(bool)
                self.collectionView?.reloadData()
            }
        })
    }

    
    //--- Segues ---//

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetail" {
            guard let indexPath = collectionView?.indexPathsForSelectedItems?[0] else { return }
            guard let index = indexPathToImageIndex(indexPath) else { return }
            
            let vc = segue.destination as! ImageDetailPageVC
            
            vc.derpibooru = derpibooru
            vc.imageIndexFromSegue = index
            
            vc.hidesBottomBarWhenPushed = true
        }
    }
    

    //--- UICollectionViewDataSource ---//
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return derpibooru.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! ImageGridCell
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = Theme.current().background2.cgColor
        
        cell.backgroundColor = Theme.current().background
        cell.stackViewBackgroundView.backgroundColor = Theme.current().background2
        
        cell.favIcon.textColor = Theme.current().fav
        cell.favLabel.textColor = Theme.current().fav
        cell.upvIcon.textColor = Theme.current().upv
        cell.scoreLabel.textColor = Theme.current().labelText
        cell.dnvIcon.textColor = Theme.current().dnv
        cell.commentIcon.textColor = Theme.current().comment
        cell.commentLabel.textColor = Theme.current().comment
        
        if let dbImage = dbImageFromIndexPath(indexPath) {
            cell.favLabel.text = "\(dbImage.faves ?? 0)"
            cell.scoreLabel.text = "\(dbImage.score ?? 0)"
            cell.commentLabel.text = "\(dbImage.comment_count ?? 0)"
            
            if let image = dbImage.getImage(ofSizeType: DBImage.ImageSizeType.thumb, urlSession: urlSession, completion: onImageDownloadComplete) {
                cell.cellImageView.image = image
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as! ImageGridFooter
        
        footer.footerLabel.textColor = Theme.current().labelText
        footer.footerLabel.text = isLoadingImages == true ? "Loading" : images.count == 0 ? "" : "Loading More"
        if shouldLoadMoreImage {
            loadMoreImages({ isEndOfResults in
                if isEndOfResults {
                    footer.footerLabel.text = "End of Results"
                }
            })
        }
        
        return footer
    }
    
    func onImageDownloadComplete(_ dbImage: DBImage?) {
        DispatchQueue.main.async {
            if let dbImage = dbImage {
                guard let indexPath = self.indexPathFromDBImage(dbImage) else { return }
                
                for cell in (self.collectionView?.visibleCells)! {
                    if self.collectionView?.indexPath(for: cell) == indexPath {
                        self.collectionView?.reloadItems(at: [indexPath])
                        return
                    }
                }
            }
        }
        
    }
    
    //--- Convenience Methods ---//
    
    func indexPathToImageIndex(_ indexPath: IndexPath) -> Int? {
        if (indexPath as NSIndexPath).row < images.count {
            return (indexPath as NSIndexPath).row
        } else {
            return nil
        }
    }
    
    func imageIndexToIndexPath(_ index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }
    
    func dbImageFromIndexPath(_ indexPath: IndexPath) -> DBImage? {
        guard let index = indexPathToImageIndex(indexPath) else { return nil }
        return images[index]
    }
    
    func indexPathFromDBImage(_ dbImage: DBImage) -> IndexPath? {
        guard let index = images.index(where: {$0 === dbImage}) else { return nil }
        return imageIndexToIndexPath(index)
    }
    
    func clearImageGrid() {
        derpibooru.clearImages()
        collectionView?.reloadData()
    }
    
    
    //--- Orientation Change ---//
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //target rows: iPAD: 4 or 6, iPhone 3 or 5

        let collectionWidth = collectionView.bounds.width
        var itemWidth: CGFloat = 60
        let orientation = UIApplication.shared.statusBarOrientation
        if UI_USER_INTERFACE_IDIOM() == .pad {
            itemWidth = orientation == .portrait ? collectionWidth / 4 : collectionWidth / 6
        } else if UI_USER_INTERFACE_IDIOM() == .phone {
            itemWidth = orientation == .portrait ? collectionWidth / 3 : collectionWidth / 5
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
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
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
}

class ImageGridFooter: UICollectionReusableView {
    
    @IBOutlet weak var footerLabel: UILabel!
    
}

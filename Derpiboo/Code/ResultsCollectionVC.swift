////
////  ResultsCollectionVC.swift
////  Derpiboo
////
////  Created by Austin Chau on 12/22/15.
////  Copyright © 2015 Austin Chau. All rights reserved.
////
//
//import UIKit
//
//protocol ResultsCollectionVCDelegate {
//    
//}
//
//class ResultsCollectionVC: UICollectionViewController, DerpibooruDelegate, DBImageThumbnailDelegate {
//    
//    let cellReuseIdentifier = "resultsCell"
//    let footerReuseIdentifier = "resultsCellFooter"
//    
//    // ------------------------------------
//    // MARK: Variables / Stores
//    // ------------------------------------
//    
//    let defaultImage = UIImage(contentsOfFile: "defaultThumb.jpg")
//    var pullToRefreshControl: UIRefreshControl!
//    var searchController: UISearchController?
//    
//    // ------------------------------------
//    // MARK: ViewController Life Cycle
//    // ------------------------------------
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        //dataSource = Derpibooru.defaultInstance
//        dataSource!.setDBImageThumbailDelegate(self)
//
//        self.clearsSelectionOnViewWillAppear = false
//        
//        pullToRefreshControl = UIRefreshControl()
//        pullToRefreshControl.tintColor = UIColor.orangeColor()
//        pullToRefreshControl.addTarget(self, action: #selector(ResultsCollectionVC.pullToRefresh), forControlEvents: UIControlEvents.ValueChanged)
//        collectionView?.addSubview(pullToRefreshControl)
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        navigationController?.hidesBarsOnTap = false
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        dataSource?.didReceiveMemoryWarning()
//    }
//    
//    // ------------------------------------
//    // MARK: DerpibooruDataSource
//    // ------------------------------------
//    
//    var dataSource: DerpibooruDataSource?
//    var imageArray: [DBImage] { get { return dataSource!.imageArray } }
//    var searchTerm: String? { get { return dataSource!.searchTerm } set { dataSource!.searchTerm = newValue } }
//    let numberOfSections = 1
//    
//    // ------------------------------------
//    // MARK: DerpibooruDelegate
//    // ------------------------------------
//    
//    func searchDidReturnZeroResults() {
//        
//    }
//    
//    // ------------------------------------
//    // MARK: - Convenience Methods
//    // ------------------------------------
//    
//    func imageArrayImageAtIndexPath(indexPath: NSIndexPath) -> DBImage? {
//        if indexPath.row < imageArray.count {
//            return imageArray[indexPath.row]
//        } else {
//            return nil
//        }
//    }
//    
//    func dbImageToIndexPath(image: DBImage) -> NSIndexPath? {
//        guard let index = imageArray.indexOf(image) else { return nil }
//        return NSIndexPath(forRow: index, inSection: numberOfSections - 1)
//    }
//    
//    func indexPathToImageArrayIndex(indexPath: NSIndexPath) -> Int? {
//        guard let image = imageArrayImageAtIndexPath(indexPath) else { return nil }
//        return imageArray.indexOf(image)
//    }
//    
//    func reloadCellAtIndexPathIfVisible(indexPath: NSIndexPath) {
//        if let visibleItems = self.collectionView?.indexPathsForVisibleItems() {
//            if visibleItems.contains(indexPath) {
//                self.collectionView?.reloadItemsAtIndexPaths([indexPath])
//            }
//        }
//    }
//    
//    func clearCollectionView() {
//        dataSource!.clearDataSource()
//        self.collectionView?.reloadData()
//    }
//    
//    //for access from parent view controllers
//    func loadNewImages(query: String?) {
//        searchTerm = query
//        dataSource!.clearDataSource()
//        dataSource!.loadNewImages() { error in
//            if error == nil {
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.collectionView?.reloadData()
//                    self.scrollToTop()
//                }
//            } else { return }
//        }
//    }
//    
//    func scrollToTop() {
//        collectionView?.setContentOffset(CGPointMake(0, 0 - topLayoutGuide.length), animated: true)
//    }
//    
//    // ------------------------------------
//    // MARK: UICollectionViewDataSource
//    // ------------------------------------
//
//    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        return numberOfSections
//    }
//
//
//    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return imageArray.count
//    }
//
//    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ResultsCollectionCellVC
//        
//        cell.backgroundColor = UIColor.whiteColor()
//        if let image = imageArrayImageAtIndexPath(indexPath) {
//            cell.imageView.image = image.thumbnail
//            if let upvote = image.scores?.upvote, downvote = image.scores?.downvote, favvote = image.scores?.favvote {
//                cell.upvoteText.text = "\(upvote)"
//                cell.downvoteText.text = "\(downvote)"
//                cell.favvoteText.text = "\(favvote)"
//            }
//        }
//
//        
//        return cell
//    }
//    
//    // ------------------------------------
//    // MARK: - Navigation
//    // ------------------------------------
//    
//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier("showImageDetail", sender: self)
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "showImageDetail" {
//            let indexPath = (self.collectionView?.indexPathsForSelectedItems()![0])! as NSIndexPath
//            guard let index = indexPathToImageArrayIndex(indexPath) else { return }
//            
//            let vc = segue.destinationViewController as! ImageDetailPageVC
//            
//            vc.derpibooruDataSource = self.dataSource
//            vc.imageArrayIndexFromSegue = index
//            
//            vc.hidesBottomBarWhenPushed = true
//        }
//    }
//    
//    // -------------------
//    // Infinite Scrolling
//    // -------------------
//    
//    func pullToRefresh() {
//        dataSource!.loadNewImages() { error in
//            dispatch_async(dispatch_get_main_queue()) {
//                self.collectionView?.reloadData()
//                self.pullToRefreshControl.endRefreshing()
//            }
//        }
//    }
//    
//    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.item == (imageArray.count-1) {
//            dataSource!.loadMoreImages() { error in
//                dispatch_async(dispatch_get_main_queue()) {
//                    collectionView.reloadData()
//                }
//            }
//        }
//    }
//    
////    override func collectionView(collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
////        
////        switch elementKind {
////            
////        case UICollectionElementKindSectionFooter: break
////            
////            
////        default:
////            
////            assert(false, "Unexpected element kind")
////        }
////            
////    }
//    
//    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
//        switch kind {
//            
//        case UICollectionElementKindSectionHeader:
//            
//            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "resultsHeader", forIndexPath: indexPath)
//            
//            headerView.backgroundColor = UIColor.blueColor();
//            return headerView
//            
//        case UICollectionElementKindSectionFooter:
//            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "resultsFooter", forIndexPath: indexPath) as! ResultsCollectionFooterVC
//            
//            footerView.footerLabel.text = "loading more…"
//            
//            
//            return footerView
//            
//        default:
//            
//            assert(false, "Unexpected element kind")
//        }
//    }
//    
//    // ------------------------------------
//    // MARK: - DBImageThumbnailDelegate
//    // ------------------------------------
//
//    func thumbnailDidFinishDownloading(dbImage: DBImage) {
//        guard let indexPath = dbImageToIndexPath(dbImage) else { print("indexPath error"); return }
//        if let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? ResultsCollectionCellVC {
//            dispatch_async(dispatch_get_main_queue()) {
//                cell.imageView.image = dbImage.thumbnail
//                self.reloadCellAtIndexPathIfVisible(indexPath)
//            }
//        }
//    }
//}
//
//// -------------------
//// FlowLayout Delegate
//// -------------------
//
//extension ResultsCollectionVC: UICollectionViewDelegateFlowLayout {
//    
//    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        let collectionWidth = CGRectGetWidth(collectionView.bounds)
//        var itemWidth = collectionWidth / 3
//        
//        if(UI_USER_INTERFACE_IDIOM() == .Pad) {
//            itemWidth = collectionWidth / 4
//        }
//        
//        return CGSizeMake(itemWidth - 2, itemWidth + 20);
//    }
//    
//}
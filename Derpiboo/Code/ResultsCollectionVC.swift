//
//  ResultsCollectionVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 12/22/15.
//  Copyright © 2015 Austin Chau. All rights reserved.
//

import UIKit

class ResultsCollectionVC: UICollectionViewController, DBImageThumbnailDelegate {
    
    let cellReuseIdentifier = "resultsCell"
    let footerReuseIdentifier = "resultsCellFooter"
    
    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------
    
    let defaultImage = UIImage(contentsOfFile: "defaultThumb.jpg")
    var pullToRefreshControl: UIRefreshControl!
    var searchController: UISearchController?
    
    // ------------------------------------
    // MARK: ViewController Life Cycle
    // ------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = Derpibooru.defaultInstance
        dataSource!.setDBImageThumbailDelegate(self)

        self.clearsSelectionOnViewWillAppear = false
        
        pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.tintColor = UIColor.orangeColor()
        pullToRefreshControl.addTarget(self, action: "pullToRefresh", forControlEvents: UIControlEvents.ValueChanged)
        collectionView?.addSubview(pullToRefreshControl)
        
        dataSource!.loadNewImages(nil) { error in
            if error == nil {
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView?.reloadData()
                }
            } else { return }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // ------------------------------------
    // MARK: IBAction / IBOutlet
    // ------------------------------------
    
    @IBOutlet weak var searchButton: UIBarButtonItem!
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController!.delegate = self
        self.searchController!.searchBar.delegate = self
        
        self.searchController!.hidesNavigationBarDuringPresentation = false
        self.searchController!.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController!.searchBar
        
        self.definesPresentationContext = true
    }
    
    // ------------------------------------
    // MARK: DerpibooruDataSource
    // ------------------------------------
    
    var dataSource: DerpibooruDataSource?
    var imageArray: [DBImage] { get { return dataSource!.imageArray } }
    var searchTerm: String? { get { return dataSource!.searchTerm } set { dataSource!.searchTerm = newValue } }
    let numberOfSections = 1
    
    // ------------------------------------
    // MARK: - Convenience Methods
    // ------------------------------------
    
    func imageArrayImageAtIndexPath(indexPath: NSIndexPath) -> DBImage? {
        if indexPath.row < imageArray.count {
            return imageArray[indexPath.row]
        } else {
            return nil
        }
    }
    
    func dbImageToIndexPath(image: DBImage) -> NSIndexPath? {
        guard let index = imageArray.indexOf(image) else { return nil }
        return NSIndexPath(forRow: index, inSection: numberOfSections - 1)
    }
    
    func indexPathToImageArrayIndex(indexPath: NSIndexPath) -> Int? {
        guard let image = imageArrayImageAtIndexPath(indexPath) else { return nil }
        return imageArray.indexOf(image)
    }
    
    func reloadCellAtIndexPathIfVisible(indexPath: NSIndexPath) {
        if let visibleItems = self.collectionView?.indexPathsForVisibleItems() {
            if visibleItems.contains(indexPath) {
                self.collectionView?.reloadItemsAtIndexPaths([indexPath])
            }
        }
    }
    
    // ------------------------------------
    // MARK: UICollectionViewDataSource
    // ------------------------------------

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ResultsCollectionCellVC
        
        cell.backgroundColor = UIColor.whiteColor()
        if let image = imageArrayImageAtIndexPath(indexPath) {
            cell.imageView.image = image.thumbnail
        }
        if let index = indexPathToImageArrayIndex(indexPath) {
            cell.imageLabel.text = "\(index)"
        }
        
        return cell
    }
    
    // ------------------------------------
    // MARK: - Navigation
    // ------------------------------------
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("showImageDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImageDetail" {
            let indexPath = (self.collectionView?.indexPathsForSelectedItems()![0])! as NSIndexPath
            guard let index = indexPathToImageArrayIndex(indexPath) else { return }
            
            let vc = segue.destinationViewController as! ImageDetailPageVC
            
            vc.derpibooruDataSource = self.dataSource
            vc.imageArrayIndexFromSegue = index
            
//            //download full image here
//            imageArray[index].downloadFullImage()
        }
    }
    
    // -------------------
    // Infinite Scrolling
    // -------------------
    
    func pullToRefresh() {
        dataSource!.loadNewImages(searchTerm) { error in
            dispatch_async(dispatch_get_main_queue()) {
                self.collectionView?.reloadData()
                self.pullToRefreshControl.endRefreshing()
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.item == (imageArray.count-1) {
            dataSource!.loadMoreImages(searchTerm) { error in
                dispatch_async(dispatch_get_main_queue()) {
                    collectionView.reloadData()
                }
            }
        }
    }
    
    // ------------------------------------
    // MARK: - DBImageThumbnailDelegate
    // ------------------------------------

    func thumbnailDidFinishDownloading(dbImage: DBImage) {
        guard let indexPath = dbImageToIndexPath(dbImage) else { print("indexPath error"); return }
        if let cell = collectionView?.cellForItemAtIndexPath(indexPath) as? ResultsCollectionCellVC {
            dispatch_async(dispatch_get_main_queue()) {
                cell.imageView.image = dbImage.thumbnail
                self.reloadCellAtIndexPathIfVisible(indexPath)
            }
        }
    }
}

// ------------------------------------
// SearchControllerDelegate
// ------------------------------------

extension ResultsCollectionVC: UISearchControllerDelegate {
    func didPresentSearchController(searchController: UISearchController) {
        navigationItem.setRightBarButtonItem(nil, animated: true)
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        navigationItem.setRightBarButtonItem(searchButton, animated: true)
    }
}

// ------------------------------------
// SearchBarDelegate
// ------------------------------------

extension ResultsCollectionVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        guard let _ = searchBar.text else { return }
//        searchTerm = searchBar.text
//        dataSource?.clearImageArray()
//        collectionView?.reloadData()
//        dataSource?.loadNewImagesBySearch(searchTerm!) { error in
//            dispatch_async(dispatch_get_main_queue()) {
//                self.collectionView?.reloadData()
//            }
//        }
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        searchTerm = nil
//        imageDataSource?.clearImageArray()
//        collectionView?.reloadData()
//        imageDataSource?.loadNewImages() { error in
//            dispatch_async(dispatch_get_main_queue()) {
//                self.collectionView?.reloadData()
//            }
//        }
    }
}
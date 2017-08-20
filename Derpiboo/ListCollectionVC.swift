//
//  ListCollectionVC.swift
//  E621
//
//  Created by Austin Chau on 10/7/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit
import UIScrollView_InfiniteScroll

protocol ListCollectionVCDataSource {
    var results: [ImageResult] { get }
    var tags: [String]? { get }
    var sortBy: ListRequester.SortType { get }
    var sortOrder: ListRequester.SortOrderType { get }
    
    func getResults(asNew reset: Bool, withTags tags: [String]?, withSorting: (sortBy: ListRequester.SortType, inOrder: ListRequester.SortOrderType)?) -> Promise<Void>
    func setSorting(sortBy: ListRequester.SortType, sortOrder: ListRequester.SortOrderType)
}

/// There CollectionViewController class that deals with the vertical scroll view of lists of returned image results.
class ListCollectionVC: UICollectionViewController {
    // Mark: Constants and tags
    public static let storyboardName = "ListCollection"
    public static let storyboardID = "listCollectionVC"
    private let showImageSegueID = "showImageZoomVC"
    private let showFilterVC = "showFilterVC"

    var isFirstListCollectionVC = false
    var shouldHideNavigationBar = true
    
    // Mark: Delegates
    
    var dataSource: ListCollectionVCDataSource?
    
    // Mark: VC Life Cycle
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        setupInfiniteScroll()
        navigationController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(useE621ModeDidChange), name: Notification.Name.init(rawValue: Preferences.useE621Mode.rawValue), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Setup UI
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.getNewResultsForStupidSelector), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
    }
    
    private func setupInfiniteScroll() {
        collectionView?.infiniteScrollIndicatorStyle = .whiteLarge
        collectionView?.addInfiniteScroll { [weak self] (scrollView) -> Void in
            // Setup loading when performing infinite scroll
            let lastCount = (self?.dataSource?.results.count)!
            _ = self?.dataSource?.getResults(asNew: false, withTags: self?.dataSource?.tags, withSorting: (sortBy: self!.dataSource!.sortBy, inOrder: self!.dataSource!.sortOrder)).then { () -> Void in
                // Update collection view
                var index = [IndexPath]()
                for n in lastCount..<(self?.dataSource?.results.count)! {
                    index.append(IndexPath(item: n, section: 0))
                }
                scrollView.performBatchUpdates({ () -> Void in
                    scrollView.insertItems(at: index)
                }, completion: { (finished) -> Void in
                    scrollView.finishInfiniteScroll()
                })
            }
        }
    }
    
    func getNewResultsForStupidSelector() {
        getNewResult(withTags: nil)
    }
    
    func getNewResult(withTags tags: [String]? = nil) {
        _ = dataSource?.getResults(asNew: true, withTags: tags != nil ? tags: dataSource?.tags, withSorting: (sortBy: dataSource!.sortBy, inOrder: dataSource!.sortOrder)).then { () -> Void in
            self.collectionView?.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    // Mark: - Segues
    func segue(isTappedBy sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let point = sender.location(in: collectionView)
            if let indexPath = collectionView?.indexPathForItem(at: point) {
                performSegue(withIdentifier: showImageSegueID, sender: indexPath)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showImageSegueID {
            let destinationVC = segue.destination as! ImageZoomVC
            let index = (sender as! IndexPath).row
            let result = dataSource?.results[index]
            destinationVC.imageResult = result
        } else if segue.identifier == showFilterVC {
            let popoverVC = segue.destination as! ListCollectionFilterVC
            
            popoverVC.modalPresentationStyle = .popover
            popoverVC.popoverPresentationController!.delegate = self
            
            popoverVC.listVC = self
        }
    }
    
    // Mark: - Notification Observing
    
    func useE621ModeDidChange() {
        dataSource?.getResults(asNew: true, withTags: dataSource?.tags, withSorting: nil).then {
            self.collectionView?.reloadData()
            }.catch { error in print(error) }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.results.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Define cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionVCMainCell.storyboardID, for: indexPath) as! ListCollectionVCMainCell
        // Guard if dataSource exists
        guard let dataSource = dataSource else { return cell }
        // Safeguard if there's enough cell
        guard indexPath.row < dataSource.results.count else { return cell }
        // Setup gesture recognizer
        cell.setupImageViewGesture(receiver: self)
        // Layout the cell
        if let windowWidth = view.window?.bounds.size.width {
            cell.setupCellLayout(windowWidth: windowWidth)
        }
        // Setting the cell
        let item = dataSource.results[indexPath.row]
        let itemVM = ListCollectionVCMainCellVM(result: item)
        cell.setCellContents(indexPath: indexPath, dataSource: itemVM)
        // Done
        return cell
    }
    
    // Mark: - Scroll View
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        //print("dragging")
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            changeTabBar(hidden: true, animated: true)
        } else {
            changeTabBar(hidden: false, animated: true)
        }
    }
    
    func changeTabBar(hidden:Bool, animated: Bool){
        let tabBar = self.tabBarController?.tabBar
        if tabBar!.isHidden == hidden { return }
        let frame = tabBar?.frame
        let offset = (hidden ? (frame?.size.height)! : -(frame?.size.height)!)
        let duration: TimeInterval = (animated ? 0.5 : 0.0)
        tabBar?.isHidden = false
        if frame != nil {
            UIView.animate(withDuration: duration, animations: {
                tabBar!.frame = tabBar!.frame.offsetBy(dx: 0, dy: offset)
            }, completion: {
                if $0 {
                    tabBar?.isHidden = hidden
                }
            })
        }
    }
}

// MARK: - Nav Controller Delegate

extension ListCollectionVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is ListCollectionVC {
            navigationController.setNavigationBarHidden(shouldHideNavigationBar, animated: animated)
            navigationController.hidesBarsOnSwipe = !shouldHideNavigationBar
        } else {
            navigationController.setNavigationBarHidden(false, animated: animated)
            navigationController.hidesBarsOnSwipe = false
        }
    }
}

extension ListCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = {
            var w = view.window?.bounds.size.width ?? 375
            if w > 480 { w = 480 }
            return w
        }()
        
        guard let dataSource = dataSource, indexPath.row < dataSource.results.count else { return CGSize(width: width, height: 0) }
        
        let itemMetadata = dataSource.results[indexPath.row].metadata
        let imageHeight = itemMetadata.height
        let imageWidth = itemMetadata.width
        let correctedImageHeight = width / CGFloat(imageWidth) * CGFloat(imageHeight)
        
        
        let height = 60 + 50 + correctedImageHeight
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1000
    }
}

// Mark: - Popover Presentation Delegate

extension ListCollectionVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}














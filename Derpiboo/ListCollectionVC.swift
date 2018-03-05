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
    var sortFilter: SortFilter { get }
    
    func getResults(asNew reset: Bool, withTags tags: [String]?, withSorting: SortFilter?) -> Promise<Void>
    func setSorting(filter: SortFilter)
}

/// There CollectionViewController class that deals with the vertical scroll view of lists of returned image results.
class ListCollectionVC: UICollectionViewController {
    
    // MARK: - Declarations
    
    enum Errors: Error {
        case setupInfiniteScrollFailed
    }
    
    // MARK: Constants and tags
    public static let storyboardName = "ListCollection"
    public static let storyboardID = "listCollectionVC"
    private let showImageSegueID = "showImageZoomVC"
    private let showFilterVC = "showFilterVC"

    var isFirstListCollectionVC = false
    var shouldHideNavigationBar = true
    
    // MARK: Delegates
    
    var dataSource: ListCollectionVCDataSource?
    
    // MARK: VC Life Cycle
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefreshControl()
        setupInfiniteScroll()
        navigationController?.delegate = self
        if #available(iOS 11, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
        }
        if isFirstListCollectionVC {
            navigationItem.rightBarButtonItems = nil
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterDidChange), name: Notification.Name(FilterManager.currentFilterDidChangeName), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        //print("rotating VC")
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // Setup UI
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.getNewResultsForStupidSelector), for: .valueChanged)
        collectionView?.addSubview(refreshControl)
    }
    
    // TODO: - Fix loading next page so that it can detect fails.
    private func setupInfiniteScroll() {
        collectionView?.infiniteScrollIndicatorStyle = .whiteLarge
        collectionView?.addInfiniteScroll { [weak self] (scrollView) -> Void in
            // Setup loading when performing infinite scroll
            firstly { () -> Promise<(Void, Int)> in
                guard let lastCount = self?.dataSource?.results.count,
                    let dataSource = self?.dataSource else { return Promise(error: Errors.setupInfiniteScrollFailed) }
                return dataSource.getResults(asNew: false, withTags: dataSource.tags, withSorting: nil).then { return ($0, lastCount) }
            }.then { (_, lastCount) -> Void in
                // Update collection view
                guard let dataSource = self?.dataSource else { throw Errors.setupInfiniteScrollFailed }
                var index = [IndexPath]()
                for n in lastCount..<dataSource.results.count {
                    index.append(IndexPath(item: n, section: 0))
                }
                scrollView.performBatchUpdates({ () -> Void in
                    scrollView.insertItems(at: index)
                }, completion: { (finished) -> Void in
                    scrollView.finishInfiniteScroll()
                })
            }.catch { error in print(error) }
        }
    }
    
    func getNewResultsForStupidSelector() {
        #if DEBUG
            print("refreshing")
        #endif
        getNewResult(withTags: nil)
    }
    
    func getNewResult(withTags tags: [String]? = nil) {
        dataSource?.getResults(asNew: true, withTags: tags != nil ? tags: dataSource?.tags, withSorting: nil).then { () -> Void in
            self.collectionView?.reloadData()
            /*
            self.collectionView?.performBatchUpdates({
                guard let indexCount = self.collectionView?.numberOfItems(inSection: 0) else { return }
                for n in 0..<indexCount {
                    let indexPath = IndexPath(item: n, section: 0)
                    self.collectionView?.deleteItems(at: [indexPath])
                }
                }, completion: { success in
                    self.refreshControl.endRefreshing()
            })
             */
            self.refreshControl.endRefreshing()
            }.catch { error in
                print(error)
        }
    }
    
    // MARK: - Segues
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
            
            popoverVC.delegate = self
        }
    }
    
    // MARK: - Notification Observing
    
    func filterDidChange() {
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
        cell.setupCellLayout(windowWidth: view.window?.bounds.width ?? view.bounds.width)
        cell.setCellContents(indexPath: indexPath, dataSource: itemVM)
        // Done
        return cell
    }
    
    /*override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ListCollectionVCMainCell {
            cell.animateImage()
        }
    }*/
}

// MARK: - Nav Controller Delegate

extension ListCollectionVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is ListCollectionVC {
            navigationController.setNavigationBarHidden(false, animated: animated)
            //navigationController.hidesBarsOnSwipe = !shouldHideNavigationBar
        } else {
            navigationController.setNavigationBarHidden(false, animated: animated)
            navigationController.hidesBarsOnSwipe = false
        }
    }
}

extension ListCollectionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = {
            var w = (view.window?.bounds.size.width ?? 375) - 32
            if w > 480 { w = 480 }
            return w
        }()
        
        guard let dataSource = dataSource, indexPath.row < dataSource.results.count else { return CGSize(width: width, height: 0) }
        
        let itemMetadata = dataSource.results[indexPath.row].metadata
        let imageHeight = itemMetadata.height
        let imageWidth = itemMetadata.width
        let correctedImageHeight = width / CGFloat(imageWidth) * CGFloat(imageHeight)
        
        // If the image is too long, shrink it
        
        let ratio = correctedImageHeight / width
        let height: CGFloat = {
            if ratio > 3 {
                return correctedImageHeight * (sqrt(1 / ratio))
            } else {
                return correctedImageHeight
            }
        }()
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1000
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - Popover Presentation Delegate

extension ListCollectionVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - ListCollectionFilterVCDelegate

extension ListCollectionVC: ListCollectionFilterVCDelegate {
    func filterDidApply(filter: SortFilter) {
        dataSource?.setSorting(filter: filter)
        getNewResult()
        
        collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
    
    func currentFilter() -> SortFilter? {
        return dataSource?.sortFilter
    }
    
    
}












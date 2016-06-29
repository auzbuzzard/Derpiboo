//
//  ImageGroupTableVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageGroupTableVC: UITableViewController {
    
    private let tableCellReuseIdentifier = "groupTableCell"
    private let cellReuseIdentifier = "groupCell"
    
    var derpibooru: Derpibooru!
    var mainList: [[DBImage]] { get { return derpibooru.mainList } }
    
    var imageGroupVC: ImageGroupVC!
    
    let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 190.0
        tableView.tableFooterView = UIView()
        
        //imageGroupVC = ImageGroupVC()
        
        derpibooru.loadMainList(urlSession, copyToClass: true, completion: {_ in
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return derpibooru.mainList.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard let tableViewCell = cell as? ImageGroupTableCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableCellReuseIdentifier, forIndexPath: indexPath) as! ImageGroupTableCell
        
        let listName = getListName(fromIndex: indexPath.row)
        
        cell.titleLabel.text = derpibooru.getListNameReadable(listName)
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "selectedImageGroupTableCell" {
            let vc = segue.destinationViewController as! ListsSelectedVC
            vc.selectedTableIndex = tableView.indexPathForSelectedRow?.row
            vc.selectedListName = getListName(fromIndex: (tableView.indexPathForSelectedRow?.row)!)
            vc.navigationItem.title = derpibooru.getListNameReadable(vc.selectedListName)
        }
    }
    
}

extension ImageGroupTableVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return mainList[collectionView.tag].count
    }
    
    func collectionView(collectionView: UICollectionView,
                        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ImageGridCell
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = Theme.current().background2.CGColor
        
        cell.backgroundColor = Theme.current().background
        cell.stackViewBackgroundView.backgroundColor = Theme.current().background2
        
        cell.favIcon.textColor = Theme.current().fav
        cell.favLabel.textColor = Theme.current().fav
        cell.upvIcon.textColor = Theme.current().upv
        cell.scoreLabel.textColor = Theme.current().labelText
        cell.dnvIcon.textColor = Theme.current().dnv
        cell.commentIcon.textColor = Theme.current().comment
        cell.commentLabel.textColor = Theme.current().comment
        
        if let dbImage = dbImageFromIndexPath(indexPath, tag: collectionView.tag) {
            cell.favLabel.text = "\(dbImage.faves ?? 0)"
            cell.scoreLabel.text = "\(dbImage.score ?? 0)"
            cell.commentLabel.text = "\(dbImage.comment_count ?? 0)"
            
            if let image = dbImage.getImage(ofSizeType: DBImage.ImageSizeType.thumb, urlSession: urlSession, completion: { dbImage in
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let dbImage = dbImage {
                        guard let indexPath = self.indexPathFromDBImage(dbImage, tag: collectionView.tag) else { return }
                        
                        for cell in (collectionView.visibleCells()) {
                            if collectionView.indexPathForCell(cell) == indexPath {
                                collectionView.reloadItemsAtIndexPaths([indexPath])
                                return
                            }
                        }
                    }
                }
                
            }) {
                cell.cellImageView.image = image
            }
        }
        
        return cell
    }
    
    //--- Convenience Methods ---//
    
    func indexPathToImageIndex(indexPath: NSIndexPath, tag: Int) -> Int? {
        if indexPath.row < mainList[tag].count {
            return indexPath.row
        } else {
            return nil
        }
    }
    
    func imageIndexToIndexPath(index: Int) -> NSIndexPath {
        return NSIndexPath(forItem: index, inSection: 0)
    }
    
    func dbImageFromIndexPath(indexPath: NSIndexPath, tag: Int) -> DBImage? {
        guard let index = indexPathToImageIndex(indexPath, tag: tag) else { return nil }
        return mainList[tag][index]
    }
    
    func indexPathFromDBImage(dbImage: DBImage, tag: Int) -> NSIndexPath? {
        guard let index = mainList[tag].indexOf({$0 === dbImage}) else { return nil }
        return imageIndexToIndexPath(index)
    }
    
    func getListName(fromIndex index: Int) -> String {
        return index == 0 ? "top_scoring" : index == 1 ? "top_commented" : "all_time_top_scoring"
    }
}

class ImageGroupTableCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableCollectionView: UICollectionView!
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        tableCollectionView.delegate = dataSourceDelegate
        tableCollectionView.dataSource = dataSourceDelegate
        tableCollectionView.tag = row
        tableCollectionView.reloadData()
    }
}







//
//  ImageGroupVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageGroupVC: UICollectionViewController {
    
    private let cellReuseIdentifier = "groupCell"
    private let headerReuseIdentifier = "groupHeader"
    
    var derpibooru: Derpibooru!
    var images: [DBImage] { get { return derpibooru.images } }
    
    let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
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
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerCell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: headerReuseIdentifier, forIndexPath: indexPath) as! ImageGroupHeader
        
        headerCell.headerLabel.text = derpibooru.getListNameReadable(nil)
        
        return headerCell
    }
    
    func onImageDownloadComplete(image dbImage: DBImage?) {
        dispatch_async(dispatch_get_main_queue()) {
            if let dbImage = dbImage {
                guard let indexPath = self.indexPathFromDBImage(dbImage) else { return }
                
                for cell in (self.collectionView?.visibleCells())! {
                    if self.collectionView?.indexPathForCell(cell) == indexPath {
                        self.collectionView?.reloadItemsAtIndexPaths([indexPath])
                        return
                    }
                }
            }
        }
        
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
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

}

class ImageGroupHeader: UICollectionReusableView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
}

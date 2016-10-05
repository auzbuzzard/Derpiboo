//
//  ImageGroupTableVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageGroupTableVC: UITableViewController {
    
    fileprivate let tableCellReuseIdentifier = "groupTableCell"
    fileprivate let cellReuseIdentifier = "groupCell"
    
    var derpibooru: Derpibooru!
    var mainList: [[DBImage]] { get { return derpibooru.mainList } }
    
    var imageGroupVC: ImageGroupVC!
    
    let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 190.0
        tableView.tableFooterView = UIView()
        
        //imageGroupVC = ImageGroupVC()
        
        derpibooru.loadMainList(urlSession, copyToClass: true, completion: {_ in
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return derpibooru.mainList.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? ImageGroupTableCell else { return }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: (indexPath as NSIndexPath).row)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableCellReuseIdentifier, for: indexPath) as! ImageGroupTableCell
        
        let listName = getListName(fromIndex: (indexPath as NSIndexPath).row)
        
        cell.titleLabel.text = derpibooru.getListNameReadable(listName)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectedImageGroupTableCell" {
            let vc = segue.destination as! ListsSelectedVC
            vc.selectedTableIndex = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row
            vc.selectedListName = getListName(fromIndex: ((tableView.indexPathForSelectedRow as NSIndexPath?)?.row)!)
            vc.navigationItem.title = derpibooru.getListNameReadable(vc.selectedListName)
        }
    }
    
}

extension ImageGroupTableVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        return mainList[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
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
        
        if let dbImage = dbImageFromIndexPath(indexPath, tag: collectionView.tag) {
            cell.favLabel.text = "\(dbImage.faves ?? 0)"
            cell.scoreLabel.text = "\(dbImage.score ?? 0)"
            cell.commentLabel.text = "\(dbImage.comment_count ?? 0)"
            
            if let image = dbImage.getImage(ofSizeType: DBImage.ImageSizeType.thumb, urlSession: urlSession, completion: { dbImage in
                
                DispatchQueue.main.async {
                    if let dbImage = dbImage {
                        guard let indexPath = self.indexPathFromDBImage(dbImage, tag: collectionView.tag) else { return }
                        
                        for cell in (collectionView.visibleCells) {
                            if collectionView.indexPath(for: cell) == indexPath {
                                collectionView.reloadItems(at: [indexPath])
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
    
    func indexPathToImageIndex(_ indexPath: IndexPath, tag: Int) -> Int? {
        if (indexPath as NSIndexPath).row < mainList[tag].count {
            return (indexPath as NSIndexPath).row
        } else {
            return nil
        }
    }
    
    func imageIndexToIndexPath(_ index: Int) -> IndexPath {
        return IndexPath(item: index, section: 0)
    }
    
    func dbImageFromIndexPath(_ indexPath: IndexPath, tag: Int) -> DBImage? {
        guard let index = indexPathToImageIndex(indexPath, tag: tag) else { return nil }
        return mainList[tag][index]
    }
    
    func indexPathFromDBImage(_ dbImage: DBImage, tag: Int) -> IndexPath? {
        guard let index = mainList[tag].index(where: {$0 === dbImage}) else { return nil }
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
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (_ dataSourceDelegate: D, forRow row: Int) {
        
        tableCollectionView.delegate = dataSourceDelegate
        tableCollectionView.dataSource = dataSourceDelegate
        tableCollectionView.tag = row
        tableCollectionView.reloadData()
    }
}







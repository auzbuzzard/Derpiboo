//
//  ProfileViewVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/30/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ProfileViewVC: UITableViewController {
    
    private let profileBannerRID = "profileBannerRID"
    private let profileBadgeRID = "profileBadgeRID"
    private let profileBadgeCollectionCellRID = "profileBadgeCollectionCellRID"
    
    var derpibooru: Derpibooru!
    var profile: DBProfile?
    var profileName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 160
        tableView.tableFooterView = UIView()
        
        if profileName != nil {
            derpibooru.loadProfile(profileName!, preloadAvatar: true, urlSession: nil, copyToClass: false, handler: { profile in
                self.profile = profile
                self.tableView.reloadData()
            })
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 2
        default:
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            
            if indexPath.row == 0 { //Banner
                
                let cell = tableView.dequeueReusableCellWithIdentifier(profileBannerRID, forIndexPath: indexPath) as! ProfileBannerCell
                
                cell.profileBioTextView.textColor = Theme.current().labelText
                
                if let p = profile {
                    cell.profileUsernameLabel.text = p.name
                    cell.profileBioTextView.text = p.description
                    
                    if let avatar = p.avatar {
                        cell.profileImageView.image = avatar
                    } else {
                        profile?.downloadAvatar(nil, completion: { _ in
                            cell.profileImageView.image = p.avatar
                        })
                    }
                }
                
                return cell
                
            } else if indexPath.row == 1 { //Badge
                
                let cell = tableView.dequeueReusableCellWithIdentifier(profileBadgeRID, forIndexPath: indexPath) as! ProfileBadgeCell
                
                return cell
                
            }
            
        }

        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
            if let badgeCell = cell as? ProfileBadgeCell {
                badgeCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            }
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profile?.awards.count ?? 0
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(profileBadgeCollectionCellRID, forIndexPath: indexPath) as! ProfileBadgeCollectionCell
        
        if let p = profile {
            if indexPath.row < p.awards.count {
                let award = p.awards[indexPath.row]
                cell.badgeCollectionLabel.text = award.title
                
                if let image = award.image {
                    cell.badgeCollectionImageView.image = image
                } else {
                    p.downloadAwardImage(award, urlSession: nil, completion: { image in
                        cell.badgeCollectionImageView.image = image
                        collectionView.reloadItemsAtIndexPaths([indexPath])
                    })
                }
            }
        }
        
        return cell
    }
}

class ProfileBannerCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var profileBioTextView: UITextView!
}

class ProfileBadgeCell: UITableViewCell {
    
    @IBOutlet weak var badgeCollectionView: UICollectionView!
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
        
        badgeCollectionView.delegate = dataSourceDelegate
        badgeCollectionView.dataSource = dataSourceDelegate
        //badgeCollectionView.tag = row
        badgeCollectionView.reloadData()
    }
}

class ProfileBadgeCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var badgeCollectionImageView: UIImageView!
    @IBOutlet weak var badgeCollectionLabel: UILabel!
}





//
//  AccountRootVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class AccountRootVC: UITableViewController {
    
    private let userHeaderReuseIdentifier = "accountUserHeaderCell"
    private let badgesReuseIdentifier = "badgesTableCell"
    private let badgesCollectionViewCellReuseIdentifier = "badgeCell"
    
    let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    var derpibooru: Derpibooru!
    var userProfile: DBProfile? { get { return derpibooru.profile } }
    
    private func getProfileName(completion: String -> Void) {
        if let username = derpibooru.profileName {
            return completion(username)
        }
    }
    private func getProfile(completion: DBProfile -> Void) {
        
        if let profile = derpibooru.profile {
            return completion(profile)
        } else {
            getProfileName({ username in
                self.derpibooru.loadProfile(username, preloadAvatar: true, urlSession: self.urlSession, copyToClass: true, handler: { profile in
                    return profile
                })
            })
        }
        
    }
    
    var reloadCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        derpibooru = Derpibooru()
        
        //tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        tableView.tableFooterView = UIView()
        
        if let username = derpibooru.usernameFromDefaults {
            derpibooru.loadProfile(username, preloadAvatar: true, urlSession: urlSession, copyToClass: true, handler: { profile in
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {//profile header
            
            let cell = tableView.dequeueReusableCellWithIdentifier(userHeaderReuseIdentifier, forIndexPath: indexPath) as! AccountUserHeaderCell
            
            cell.bioTextView.textColor = Theme.current().labelText
            
//            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
//            cell.profileImageView.clipsToBounds = true
            
            getProfile({ profile in
                cell.usernameLabel.text = profile.name
                cell.bioTextView.text = profile.description
                cell.profileImageView.image = profile.avatar
                
                if let avatar = profile.avatar {
                    cell.profileImageView.image = avatar
                } else {
                    profile.downloadAvatar(self.urlSession, completion: { profile in
                        if let profile = profile {
                            dispatch_async(dispatch_get_main_queue()) {
                                cell.profileImageView.image = profile.avatar
                            }
                        }
                    })
                }
                
            })
            
            return cell
            
        } else if indexPath.row == 1 { //badge
            let cell = tableView.dequeueReusableCellWithIdentifier(badgesReuseIdentifier, forIndexPath: indexPath) as! BadgesTableCell
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == NSIndexPath(forRow: 1, inSection: 0) {
            if let badgeCell = cell as? BadgesTableCell {
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

extension AccountRootVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count\(derpibooru.profile?.awards.count)")
        //return derpibooru.profile?.awards.count ?? 1
        return userProfile?.awards.count ?? 0
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(badgesCollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! BadgesCollectionViewCell
        
        if let profile = userProfile {
            if indexPath.row < profile.awards.count {
                let award = profile.awards[indexPath.row]
                cell.badgeLabel.text = award.title
                
                if let image = award.image {
                    cell.badgeIconView.image = image
                } else {
                    profile.downloadAwardImage(award, urlSession: self.urlSession, completion: { image in
                        cell.badgeIconView.image = image
                        collectionView.reloadItemsAtIndexPaths([indexPath])
                    })
                }
            }
        }
        
//        getProfile({ profile in
//            if indexPath.row >= profile.awards.count {
//                let award = profile.awards[indexPath.row]
//                cell.badgeLabel.text = award.title
//                if let image = award.image {
//                    cell.badgeIconView.image = image
//                } else {
//                    profile.downloadAwardImage(award, urlSession: self.urlSession, completion: { image in
//                        cell.badgeIconView.image = image
//                        collectionView.reloadData()
//                    })
//                }
//                
//            }
//                
//            
//        })
//        collectionView.reloadData()
        
        return cell
    }
}

class AccountUserHeaderCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
}

class BadgesTableCell: UITableViewCell {
    
    @IBOutlet weak var badgesLabel: UILabel!
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

class BadgesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var badgeIconView: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    
}








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
    
    var reloadCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        derpibooru = Derpibooru()
        
        tableView.rowHeight = UITableViewAutomaticDimension
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
            
            let profile = derpibooru.profile
            
            if derpibooru.profile != nil {
                
                cell.usernameLabel.text = profile?.name
                cell.bioTextView.text = profile?.description
                cell.profileImageView.image = profile?.avatar
                
                if let avatar = profile?.avatar {
                    cell.profileImageView.image = avatar
                } else {
                    profile?.downloadAvatar(urlSession, completion: { profile in
                        if let profile = profile {
                            dispatch_async(dispatch_get_main_queue()) {
                                cell.profileImageView.image = profile.avatar
                            }
                        }
                    })
                }
                                
            } else {
                if let username = derpibooru.profileName {
                    derpibooru.loadProfile(username, preloadAvatar: true, urlSession: urlSession, copyToClass: false, handler: { profile in
                        if let _ = profile {
                            dispatch_async(dispatch_get_main_queue()) {
                                if self.reloadCount < 5 {
                                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                                    self.reloadCount += 1
                                }
                            }
                        }
                    })
                } else {
                    
                }
            }
            
            return cell
            
        } else if indexPath.row == 1 { //badge
            let cell = tableView.dequeueReusableCellWithIdentifier(badgesReuseIdentifier, forIndexPath: indexPath) as! BadgesTableCell
            
            return cell
        } else {
            return UITableViewCell()
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

class AccountUserHeaderCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
}

class BadgesTableCell: UITableViewCell {
    
    @IBOutlet weak var badgesLabel: UILabel!
    @IBOutlet weak var badgeCollectionView: UICollectionView!
    
    
}

class BadgesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var badgeIconView: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    
}








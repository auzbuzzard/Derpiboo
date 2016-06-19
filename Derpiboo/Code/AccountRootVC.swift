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
        
        view.backgroundColor = Utils.color().background
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {//profile header
            
            let cell = tableView.dequeueReusableCellWithIdentifier(userHeaderReuseIdentifier, forIndexPath: indexPath) as! AccountUserHeaderCell
            
            cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
            cell.imageView?.clipsToBounds = true
            cell.backgroundColor = Utils.color().background2
            
            var profile = derpibooru.profile
            
            if derpibooru.profileName != nil && derpibooru.profile != nil {
                
                cell.usernameLabel.text = profile?.name
                cell.bioLabel.text = profile?.description
                cell.profileImageView.image = profile?.avatar
                
                if let avatar = profile?.avatar {
                    cell.profileImageView.image = avatar
                } else {
                    profile?.downloadAvatar(urlSession) {
                        image, error in
                        cell.profileImageView.image = image.avatar
                        cell.imageView?.layer.cornerRadius = (cell.imageView?.frame.size.width)! / 2
                        cell.imageView?.clipsToBounds = true
                    }
                }
                                
            } else {
                if let username = derpibooru.profileName {
                    derpibooru.loadProfile(username) {
                        profile in
                        if self.reloadCount < 5 {
                            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            self.reloadCount += 1
                        }
                    }
                } else {
                    
                }
            }
            
            return cell
            
        } else if indexPath.row == 1 { //badge
            let cell = tableView.dequeueReusableCellWithIdentifier(badgesReuseIdentifier, forIndexPath: indexPath) as! BadgesTableCell
            
            cell.backgroundColor = Utils.color().background2
            
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
    @IBOutlet weak var bioLabel: UILabel!
    
}

class BadgesTableCell: UITableViewCell {
    
    @IBOutlet weak var badgesLabel: UILabel!
    @IBOutlet weak var badgeCollectionView: UICollectionView!
    
    
}

class BadgesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var badgeIconView: UIImageView!
    @IBOutlet weak var badgeLabel: UILabel!
    
    
}








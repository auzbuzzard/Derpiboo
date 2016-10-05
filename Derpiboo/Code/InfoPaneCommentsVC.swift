//
//  InfoPaneCommentsVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/20/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class InfoPaneCommentsVC: UITableViewController {
    
    fileprivate let cellReuseIdentifier = "infoPaneCommentsCell"
    
    let urlSession = URLSession(configuration: URLSessionConfiguration.default)
    
    var derpibooru: Derpibooru!
    var dbImage: DBImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 190.0
        tableView.tableFooterView = UIView()
        
        refreshControl?.addTarget(self, action: #selector(InfoPaneCommentsVC.handleRefresh), for: UIControlEvents.valueChanged)
        
        loadComments(false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("scrollviewinset: \(tableView.contentInset)")
    }
    
    fileprivate func loadComments(_ stopRefresh: Bool) {
        derpibooru.loadComments(image_id: dbImage.id, preloadProfile: false, preloadAvatar: false, urlSession: urlSession, copyToClass: false, handler: { comments in
            self.dbImage.comments = comments.reversed()
            self.tableView.reloadData()
            if stopRefresh {
                self.refreshControl?.endRefreshing()
            }
        })
    }
    
    func handleRefresh() {
        loadComments(true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let comment = dbImage.comments {
            return comment.count
        } else {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! InfoPaneCommentsCell
        
        cell.contentField.textColor = Theme.current().labelText
        
        if let comments = dbImage.comments {
            let comment = comments[(indexPath as NSIndexPath).row]
            cell.titleLabel.text = comment.author 
            cell.contentField.text = comment.body 
            
            if let profile = comment.authorProfile {
                if let avatar = profile.avatar {
                    cell.avatarImageView.image = avatar
                } else {
                    profile.downloadAvatar(urlSession, completion: { profile in
                        cell.avatarImageView.image = profile?.avatar
                    })
                }
            } else {
                let name = comment.author.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: "-", with: "-dash-")
                derpibooru.loadProfile(name, preloadAvatar: true, urlSession: urlSession, copyToClass: true, handler: { profile in
                    //print("ok for \(indexPath.row)")
                    comment.authorProfile = profile
                    
                    if let profile = profile {
                        if let avatar = profile.avatar {
                            cell.avatarImageView.image = avatar
                        } else {
                            profile.downloadAvatar(self.urlSession, completion: { profile in
                                cell.avatarImageView.image = profile?.avatar
                            })
                        }
                    }
                })
            }
            
        }
        
        let fixedWidth = cell.contentField.frame.size.width
        let newSize = cell.contentField.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        cell.contentField.frame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)

        return cell
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

class InfoPaneCommentsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentField: UITextView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = UIImage(named: "no_avatar")
    }
}












//
//  MenuTableVC.swift
//  E621
//
//  Created by Austin Chau on 10/8/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class MenuTableVC: UITableViewController {
    
    let profileCellID = "profileCell"
    let defaultCellID = "defaultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        tableView.backgroundColor = Theme.colors().background
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: profileCellID, for: indexPath) as! MenuTableVCProfileCell
            
            cell.profileLabel.textColor = Theme.colors().labelText
            /*
            if Identity.main.isLoggedIn == true {
                let user = Identity.main.user!
                cell.profileLabel.text = user.metadata.name
                if let avatar_id = user.metadata.avatar_id {
                    _ = ImageRequester().get(imageOfId: avatar_id) { result in
                        _ = result.getImage(ofSize: .thumb, callback: { image, id, error in
                            if error == nil {
                                DispatchQueue.main.async {
                                    cell.profileImageView.image = image
                                    self.tableView.reloadRows(at: [indexPath], with: .none)
                                }
                            } else {
                                print("load image error")
                            }
                        })
                    }
                }
            } else {
                cell.profileLabel.text = "Not logged in"
            }
            */
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellID, for: indexPath) as! MenuTableVCDefaultCell
            
            cell.mainLabel.textColor = Theme.colors().labelText
            
            cell.mainLabel.text = "Settings"
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 80
        case 1: return 50
        default: return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                performSegue(withIdentifier: "showSignInSheet", sender: self)
            default:
                tableView.deselectRow(at: indexPath, animated: true)
            }
            
        case 1:
            switch indexPath.row {
            case 0: performSegue(withIdentifier: "showSettingsTableVC", sender: self)
            default: tableView.deselectRow(at: indexPath, animated: true)
            }
        default: tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignInSheet" {
            
        } else if segue.identifier == "showSettingsTableVC" {
            //let settingsTableVC = segue.destination
            
        }
    }
    
    
}

extension MenuTableVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            navigationController.setNavigationBarHidden(false, animated: animated)
        } else {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
    }
}

class MenuTableVCProfileCell: UITableViewCell {
    
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    
}

class MenuTableVCDefaultCell: UITableViewCell {
    
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
}







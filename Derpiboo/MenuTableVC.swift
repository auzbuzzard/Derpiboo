//
//  MenuTableVC.swift
//  E621
//
//  Created by Austin Chau on 10/8/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class MenuTableVC: UITableViewController {
    
    fileprivate let profileCellID = "menuTableVCProfileCell"
    fileprivate let defaultCellID = "menuTableVCDefaultCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Account"
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
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
            
            cell.setupLayout()
            cell.setupContent()

            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultCellID, for: indexPath) as! MenuTableVCDefaultCell
            
            cell.setupLayout()
            cell.setupContent()
            
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
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSignInSheet" {
            
        } else if segue.identifier == "showSettingsTableVC" {
            //let settingsTableVC = segue.destination
            
        }
    }
    
    
}

class MenuTableVCProfileCell: UITableViewCell {
    
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    
    func setupLayout() {
        profileLabel.textColor = Theme.colors().labelText
        
        profileImageView.layer.cornerRadius = 10
        profileImageView.layer.masksToBounds = true
    }
    
    func setupContent() {
        profileLabel.text = "(Not Logged in)"
        profileImageView.image = #imageLiteral(resourceName: "no_avatar")
    }
    
}

class MenuTableVCDefaultCell: UITableViewCell {
    
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var mainLabel: UILabel!
    
    func setupLayout() {
        mainLabel.textColor = Theme.colors().labelText
        
        mainImageView.layer.cornerRadius = 10
        mainImageView.layer.masksToBounds = true
    }
    
    func setupContent() {
        mainLabel.text = "Settings"
    }
    
}







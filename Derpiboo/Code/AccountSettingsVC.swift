//
//  AccountSettingsVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/19/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit
import SafariServices

class AccountSettingsVC: UITableViewController, SFSafariViewControllerDelegate {
    
    let defaults = UserDefaults.standard

    @IBOutlet weak var usernameField: UITextField!
    @IBAction func usernameFieldEnter(_ sender: UITextField) {
        defaults.setValue(sender.text!, forKey: "username")
    }
    @IBOutlet weak var apiField: UITextField!
    @IBAction func apiFieldEnter(_ sender: UITextField) {
        defaults.setValue(sender.text!, forKey: "userAPIKey")
    }
    @IBOutlet weak var apiSwitch: UISwitch!
    @IBAction func apiSwitchToggled(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "userAPIKeySwitch")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.current().background

        if let username = defaults.string(forKey: "username") {
            usernameField.text = username
        }
        if let api = defaults.string(forKey: "userAPIKey") {
            apiField.text = api
        }
        if defaults.object(forKey: "userAPIKeySwitch") != nil {
            apiSwitch.isOn = defaults.bool(forKey: "userAPIKeySwitch")
        } else {
            defaults.set(true, forKey: "userAPIKeySwitch")
            apiSwitch.isOn = defaults.bool(forKey: "userAPIKeySwitch")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = Theme.current().background2
        cell.tintColor = Theme.current().labelText
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            getAPIKeyFromDB()
        }
        if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
            getFilterSettingsFromDB()
        }
    }
    
    func getAPIKeyFromDB() {
        let url = URL(string: "https://derpibooru.org/users/edit")
        let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    func getFilterSettingsFromDB() {
        let url = URL(string: "https://derpibooru.org/filters")
        let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: false)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
}

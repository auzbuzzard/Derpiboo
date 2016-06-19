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
    
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var usernameField: UITextField!
    @IBAction func usernameFieldEnter(sender: UITextField) {
        defaults.setValue(sender.text!, forKey: "username")
    }
    @IBOutlet weak var apiField: UITextField!
    @IBAction func apiFieldEnter(sender: UITextField) {
        defaults.setValue(sender.text!, forKey: "userAPIKey")
    }
    @IBOutlet weak var apiSwitch: UISwitch!
    @IBAction func apiSwitchToggled(sender: UISwitch) {
        defaults.setBool(sender.on, forKey: "userAPIKeySwitch")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Utils.color().background

        if let username = defaults.stringForKey("username") {
            usernameField.text = username
        }
        if let api = defaults.stringForKey("userAPIKey") {
            apiField.text = api
        }
        if defaults.objectForKey("userAPIKeySwitch") != nil {
            apiSwitch.on = defaults.boolForKey("userAPIKeySwitch")
        } else {
            defaults.setBool(true, forKey: "userAPIKeySwitch")
            apiSwitch.on = defaults.boolForKey("userAPIKeySwitch")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = Utils.color().background2
        cell.tintColor = Utils.color().labelText
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            getAPIKeyFromDB()
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            getFilterSettingsFromDB()
        }
    }
    
    func getAPIKeyFromDB() {
        let url = NSURL(string: "https://derpibooru.org/users/edit")
        let svc = SFSafariViewController(URL: url!, entersReaderIfAvailable: false)
        svc.delegate = self
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    func getFilterSettingsFromDB() {
        let url = NSURL(string: "https://derpibooru.org/filters")
        let svc = SFSafariViewController(URL: url!, entersReaderIfAvailable: false)
        svc.delegate = self
        self.presentViewController(svc, animated: true, completion: nil)
    }
}

//
//  SettingTableVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 12/28/15.
//  Copyright © 2015 Austin Chau. All rights reserved.
//

import UIKit
import SafariServices

class SettingTableVC: UITableViewController, SFSafariViewControllerDelegate {
    
    // ------------------------------------
    // MARK: ViewController Life Cycle
    // ------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let api = defaults.stringForKey("userAPIKey") {
            userAPIKeyField.text = api
        }
        if defaults.objectForKey("userAPIKeySwitch") != nil {
            userAPIKeySwitch.on = defaults.boolForKey("userAPIKeySwitch")
        } else {
            defaults.setBool(true, forKey: "userAPIKeySwitch")
            userAPIKeySwitch.on = defaults.boolForKey("userAPIKeySwitch")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // ------------------------------------
    // MARK: IBAction / IBOutlet
    // ------------------------------------
    
    @IBOutlet var userAPIKeyField: UITextField!
    @IBOutlet var userAPIKeySwitch: UISwitch!
    
    @IBAction func userAPIKeyEnter(sender: UITextField) {
        defaults.setValue(sender.text!, forKey: "userAPIKey")
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func useAPIKeyToggle(sender: UISwitch) {
        defaults.setBool(sender.on, forKey: "userAPIKeySwitch")
    }
    
    // ------------------------------------
    // MARK: TableViewVC
    // ------------------------------------
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            getAPIKeyFromDB()
        }
        if indexPath.section == 2 && indexPath.row == 0 {
            getFilterSettingsFromDB()
        }
    }
    
    
    // ------------------------------------
    // MARK: backend
    // ------------------------------------
    
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

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
        
        if let api = defaults.string(forKey: "userAPIKey") {
            userAPIKeyField.text = api
        }
        if defaults.object(forKey: "userAPIKeySwitch") != nil {
            userAPIKeySwitch.isOn = defaults.bool(forKey: "userAPIKeySwitch")
        } else {
            defaults.set(true, forKey: "userAPIKeySwitch")
            userAPIKeySwitch.isOn = defaults.bool(forKey: "userAPIKeySwitch")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------
    
    let defaults = UserDefaults.standard
    
    // ------------------------------------
    // MARK: IBAction / IBOutlet
    // ------------------------------------
    
    @IBOutlet var userAPIKeyField: UITextField!
    @IBOutlet var userAPIKeySwitch: UISwitch!
    
    @IBAction func userAPIKeyEnter(_ sender: UITextField) {
        defaults.setValue(sender.text!, forKey: "userAPIKey")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func useAPIKeyToggle(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "userAPIKeySwitch")
    }
    
    // ------------------------------------
    // MARK: TableViewVC
    // ------------------------------------
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            getAPIKeyFromDB()
        }
        if (indexPath as NSIndexPath).section == 2 && (indexPath as NSIndexPath).row == 0 {
            getFilterSettingsFromDB()
        }
    }
    
    
    // ------------------------------------
    // MARK: backend
    // ------------------------------------
    
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

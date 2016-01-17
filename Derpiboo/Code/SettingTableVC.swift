//
//  SettingTableVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 12/28/15.
//  Copyright © 2015 Austin Chau. All rights reserved.
//

import UIKit

class SettingTableVC: UITableViewController {
    
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

}

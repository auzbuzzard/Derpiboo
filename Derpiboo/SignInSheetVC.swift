//
//  SignInSheetVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 10/19/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class SignInSheetVC: UIViewController {
    
    @IBOutlet weak var userField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        
        if let username = userField.text, let password = passwordField.text {
            let remember_me = rememberMeSwitch.isOn
            
            //Identity.main.signIn(user: username, password: password, remember_me: remember_me)
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

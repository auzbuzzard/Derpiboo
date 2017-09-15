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
    @IBOutlet weak var signInButton: UIButton!
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    func setupLayout() {
        title = "Sign In"
        
        view.backgroundColor = Theme.colors().background
        
        userField.textColor = Theme.colors().labelText
        userField.backgroundColor = Theme.colors().background2
        passwordField.textColor = Theme.colors().labelText
        passwordField.backgroundColor = Theme.colors().background2
        
        
        
        rememberMeSwitch.onTintColor = Theme.colors().highlight
        signInButton.tintColor = Theme.colors().labelLink
    }

}

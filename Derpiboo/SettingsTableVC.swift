//
//  SettingsTableVC.swift
//  E621
//
//  Created by Austin Chau on 10/8/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class SettingsTableVC: UITableViewController {
    
    @IBOutlet weak var filterCellMainLabel: UILabel!
    @IBOutlet weak var filterCellDetailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(filterDidChange), name: Notification.Name(FilterManager.currentFilterDidChangeName), object: nil)
        
        setupContent()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupLayout() {
        title = "Settings"
        
        filterCellMainLabel.textColor = Theme.colors().labelText
        filterCellDetailLabel.textColor = Theme.colors().labelText
    }
    
    func setupContent() {
        filterCellDetailLabel.text = FilterManager.main.currentFilter?.name
    }
    
    func filterDidChange() {
        filterCellDetailLabel.text = FilterManager.main.currentFilter?.name
    }
}

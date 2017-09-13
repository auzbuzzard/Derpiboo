//
//  ImageDetailVCLabelCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/13/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit

class ImageDetailVCLabelCell: UITableViewCell {
    
    static let storyboardID = "imageDetailVCLabelCell"

    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    
    func setupLayout() {
        //BkgdView
        bkgdView.backgroundColor = Theme.colors().background2
        
        bkgdView.layer.cornerRadius = 10
        bkgdView.layer.masksToBounds = true
        
        bkgdView.backgroundColor = Theme.colors().background2
    }
    
    func setupContent(text: String?) {
        mainLabel.text = text
    }
}

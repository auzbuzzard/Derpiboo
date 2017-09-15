//
//  ImageDetailVCHeaderView.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/13/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit

class ImageDetailVCHeaderView: UIView {

    @IBOutlet weak var mainLabel: UILabel!

    func setupLayout() {
        backgroundColor = Theme.colors().background
        mainLabel.textColor = Theme.colors().labelText
    }
}

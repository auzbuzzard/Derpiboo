//
//  FiltersSelectionTableVCCell.swift
//  Derpiboo
//
//  Created by Austin Chau on 9/14/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit

class FiltersSelectionTableVCCell: UITableViewCell {
    
    static let storyboardID = "filtersSelectionTableVCCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    func setupLayout() {
        titleLabel.textColor = Theme.colors().labelLink
        descriptionTextField.textColor = Theme.colors().labelText
    }
    
    func setupContent(filterResult: FilterResult) {
        titleLabel.text = filterResult.metadata.name
        descriptionTextField.text = filterResult.metadata.description
    }
    
}

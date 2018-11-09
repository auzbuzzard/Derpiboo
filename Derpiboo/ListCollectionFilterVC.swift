//
//  ListCollectionFilterVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/19/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit

protocol ListCollectionFilterVCDelegate {
    func filterDidApply(filter: SortFilter)
    func currentFilter() -> SortFilter?
}

class ListCollectionFilterVC: UIViewController {
    
    // Mark: - Class references
    var delegate: ListCollectionFilterVCDelegate?
    
    // Mark: - Properties
    let pickerTextField = UITextField()
    
    fileprivate var selectedSortBy: SortFilter.SortType!
    fileprivate var selectedSortOrder: SortFilter.SortOrderType!
    
    // Mark: - IBOutlets
    @IBOutlet weak var sortByPickerButton: UIButton!
    @IBOutlet weak var sortOrderSC: UISegmentedControl!
    @IBOutlet weak var applyButton: UIButton!
    
    // Mark: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSortBy = delegate?.currentFilter()?.sortBy ?? .creationDate
        selectedSortOrder = delegate?.currentFilter()?.sortOrder ?? .descending
        
        setupTheme()
        setupContent()
    }
    
    func setupTheme() {
        view.backgroundColor = Theme.colors().background
        sortByPickerButton.tintColor = Theme.colors().labelText
        sortByPickerButton.backgroundColor = Theme.colors().background2
        applyButton.tintColor = Theme.colors().labelText
        applyButton.backgroundColor = Theme.colors().background2
        sortOrderSC.tintColor = Theme.colors().labelText
        
        popoverPresentationController?.backgroundColor = view.backgroundColor
    }
    
    func setupContent() {
        sortByPickerButton.setTitle(selectedSortBy.description, for: .normal)
        sortOrderSC.selectedSegmentIndex = {
            switch selectedSortOrder {
            case .descending?: return 0
            case .ascending?: return 1
            default: return 0
            }
        }()
        sortOrderSC.sendActions(for: .valueChanged)
        
        setupPickerField()
    }
    
    func setupPickerField() {
        view.addSubview(pickerTextField)
        
        let pickerView = UIPickerView()
        pickerView.showsSelectionIndicator = true
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.backgroundColor = Theme.colors().background
        
        pickerTextField.inputView = pickerView
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.barStyle = .blackOpaque
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneTouched(sender:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelTouched(sender:)))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        pickerTextField.inputAccessoryView = toolbar
    }

    // Mark: - Actions
    
    @IBAction func sortByPickerButtonIsClicked(_ sender: UIButton) {
        pickerTextField.becomeFirstResponder()
    }
    @IBAction func sortOrderSCDidChangeValue(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: selectedSortOrder = .descending
        case 1: selectedSortOrder = .ascending
        default: break
        }
    }
    @IBAction func applyButtonIsClicked(_ sender: UIButton) {
        delegate?.filterDidApply(filter: SortFilter(sortBy: selectedSortBy, sortOrder: selectedSortOrder))
        dismiss(animated: true, completion: nil)
    }
    
    // Mark: - Action for PickerView
    func cancelTouched(sender: UIBarButtonItem) {
        pickerTextField.resignFirstResponder()
    }
    
    func doneTouched(sender: UIBarButtonItem) {
        pickerTextField.resignFirstResponder()
    }
}

extension ListCollectionFilterVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return SortFilter.SortType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let type = SortFilter.SortType(rawValue: row) else { return nil }
        let title = type.description
        return NSAttributedString(string: title, attributes: [
            NSForegroundColorAttributeName : Theme.colors().labelText
            ])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let type = SortFilter.SortType(rawValue: row) else { return }
        sortByPickerButton.setTitle(type.description, for: .normal)
        selectedSortBy = type
    }
}








//
//  FiltersSelectionTableVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 10/19/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class FiltersSelectionTableVC: UITableViewController {
    
    var filterListResult: FilterListResult?
    var selectedFilterIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        setupResult()
        
    }
    
    // MARK: - Refresh
    
    func refresh() {
        FilterManager.main.reloadListResult()
        setupResult()
    }
    
    func setupResult() {
        FilterManager.main.filterListResult.then { result -> Void in
            self.filterListResult = result
            if let filterIndex = self.filterListResult?.system_filters.index(where: { filter in
                if let storedID = FilterManager.main.storedSelectedFilterID() {
                    return filter.id == storedID
                } else {
                    return filter.metadata.name == "Default"
                }
            }) {
                self.selectedFilterIndex = filterIndex
                FilterManager.main.currentFilter = result.system_filters[filterIndex]
                self.tableView.selectRow(at: IndexPath(row: filterIndex, section: 0), animated: false, scrollPosition: .none)
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
            }.catch { error in print(error) }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterListResult?.system_filters.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FiltersSelectionTableVCCell.storyboardID, for: indexPath) as! FiltersSelectionTableVCCell
        
        cell.setupLayout()
        
        guard let systemFilters = filterListResult?.system_filters, systemFilters.count > indexPath.row else { return cell }
        
        cell.setupContent(filterResult: systemFilters[indexPath.row])
        if selectedFilterIndex == indexPath.row {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedFilterIndex == indexPath.row {
            return
        } else {
            // Deselect previous cell
            tableView.cellForRow(at: IndexPath(row: selectedFilterIndex, section: indexPath.section))?.accessoryType = .none
         
            // Edit current cell
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            
            // Set data
            changeSelectedFilter(to: indexPath.row)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    // MARK: - Internal Methods
    
    func changeSelectedFilter(to index: Int) {
        print("Changing filter from \(selectedFilterIndex) \(String(describing: filterListResult?.system_filters[selectedFilterIndex].name)) to \(index) \(String(describing: filterListResult?.system_filters[index].name))")
        guard let filterListResult = filterListResult, index < filterListResult.system_filters.count else { return }
        let filter = filterListResult.system_filters[index]
        selectedFilterIndex = index
        FilterManager.main.storeSelectedFilterID(filter.id)
        FilterManager.main.currentFilter = filter
    }
}












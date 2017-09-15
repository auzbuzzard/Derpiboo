//
//  FiltersSelectionTableVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 10/19/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class FiltersSelectionTableVC: UITableViewController {
    
    var selectedFilterIndex: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Filters"
        
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.allowsMultipleSelection = false
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        setupResult()
        
    }
    
    // MARK: - Refresh
    
    func refresh() {
        FilterManager.main.reloadListResult().then {
            self.setupResult()
        }.catch { error in print(error) }
    }
    
    func setupResult() {
        FilterManager.main.reloadListResult().then { Void -> Void in
            self.selectedFilterIndex = self.filterIDToIndex(id: FilterManager.main.currentFilterID)
            self.tableView.selectRow(at: self.selectedFilterIndex, animated: false, scrollPosition: .none)
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }.catch { error in print(error) }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return FilterManager.main.filters[FilterManager.FilterListType.system_filters]?.count ?? 0
        case 1:
            return FilterManager.main.filters[FilterManager.FilterListType.special]?.count ?? 0
        default:
            return 0
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FiltersSelectionTableVCCell.storyboardID, for: indexPath) as! FiltersSelectionTableVCCell
        
        cell.setupLayout()
        
        switch indexPath.section {
        case 0:
            guard let systemFilters = FilterManager.main.filters[FilterManager.FilterListType.system_filters], systemFilters.count > indexPath.row else { return cell }
            
            cell.setupContent(filterResult: systemFilters[indexPath.row])
            
            if selectedFilterIndex == indexPath {
                cell.accessoryType = .checkmark
            }
            
            return cell
        case 1:
            guard let specialFilters = FilterManager.main.filters[FilterManager.FilterListType.special], specialFilters.count > indexPath.row else { return cell }
            cell.setupContent(filterResult: specialFilters[indexPath.row])
            
            if selectedFilterIndex == indexPath {
                cell.accessoryType = .checkmark
            }
            
            return cell
        default:
            return cell
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = Bundle.main.loadNibNamed("ImageDetailVCHeaderView", owner: nil, options: nil)?.first as? ImageDetailVCHeaderView else { return UIView() }
        view.setupLayout()
        
        switch section {
        case 0:
            view.mainLabel.text = "System Filters"
        case 1:
            view.mainLabel.text = "Special Filters"
        default:
            view.mainLabel.text = ""
        }
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 68
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedFilterIndex == indexPath {
            return
        } else {
            guard let list: FilterManager.FilterListType = {
                switch indexPath.section {
                case 0: return FilterManager.FilterListType.system_filters
                case 1: return FilterManager.FilterListType.special
                default: return nil
                }
                }() else { return }
            
            guard let filterList = FilterManager.main.filters[list], filterList.count > indexPath.row else { return }
            let filter = filterList[indexPath.row]
            
            // Deselect previous cell
            if let index = selectedFilterIndex {
                tableView.cellForRow(at: index)?.accessoryType = .none
            }
            
            // Change selection
            changeSelectedFilter(to: filter.id, index: indexPath)
         
            // Edit current cell
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            
            
        }
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    // MARK: - Internal Methods
    
    func filterIDToIndex(id: Int) -> IndexPath? {
        for (key, value) in FilterManager.main.filters {
            if let row = value.index(where: {$0.id == id} ) {
                guard let section: Int = {
                    switch key {
                    case .system_filters: return 0
                    case .special: return 1
                    default: return nil
                    }
                }() else { continue }
                
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
    
    func changeSelectedFilter(to filterID: Int, index: IndexPath) {
        guard let filter = FilterManager.main.filter(from: filterID) else { return }
        
        #if DEBUG
            print("Changing filter from \(FilterManager.main.currentFilterID) \(String(describing: FilterManager.main.currentFilter?.name)) to \(filter.id) \(filter.name))")
        #endif
        
        FilterManager.main.currentFilterID = filter.id
        
        selectedFilterIndex = index
        FilterManager.main.storeSelectedFilterID(filter.id)
    }
}












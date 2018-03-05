//
//  SearchHomeVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 8/17/17.
//  Copyright © 2017 Austin Chau. All rights reserved.
//

import UIKit

class SearchHomeVC: UITableViewController {
    
    var searchSuggestionsVC: SearchSuggestionsVC!
    var searchController: UISearchController!
    
    private let showFilterVC = "showFilterVC"
    
    private let historyCellID = "historyCell"
    
    fileprivate var currentSortFilter = SortFilter(sortBy: .creationDate, sortOrder: .descending)
    
    // Mark: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchSuggestionsVC = storyboard?.instantiateViewController(withIdentifier: SearchSuggestionsVC.storyboardID) as! SearchSuggestionsVC
        setupSearchField()
        
        tableView.backgroundColor = Theme.colors().background
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupSearchField() {
        searchController = UISearchController(searchResultsController: searchSuggestionsVC)
        searchController.searchResultsUpdater = searchSuggestionsVC
        searchController.dimsBackgroundDuringPresentation = true
        
        searchController.searchBar.keyboardAppearance = .dark
        searchController.searchBar.barStyle = .blackTranslucent
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        searchController.searchBar.barTintColor = Theme.colors().background_header
        searchController.searchBar.placeholder = "Search for Images"
        
        searchController.searchBar.autocapitalizationType = .none
        
        if #available(iOS 11, *) {
            navigationItem.title = "Search"
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .always
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            navigationItem.titleView = searchController.searchBar
        }
    }
    
    // Mark: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showFilterVC {
            let popoverVC = segue.destination as! ListCollectionFilterVC
            
            popoverVC.modalPresentationStyle = .popover
            popoverVC.popoverPresentationController!.delegate = self
            
            popoverVC.delegate = self
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchManager.main.searches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: historyCellID, for: indexPath)
        let history = SearchManager.main.searches
        cell.textLabel?.text = history[history.count - 1 - indexPath.row].searchString
        return cell
    }
    
    // TODO: - FIX Floating Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = Bundle.main.loadNibNamed("SearchHomeVCTableHeaderView", owner: nil, options: nil)?.first as? SearchHomeVCTableHeaderView else { return UIView() }
        view.setupLayout()
        view.setupContent(delegate: self)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let index = indexPath.row
            guard index < SearchManager.main.searches.count else { return }
            let history = SearchManager.main.searches[SearchManager.main.searches.count - 1 - index]
            showResults(with: history.searchString, sortFilter: history.sortFilter)
        default: break
        }
        return
    }
    
    // Mark: - Methods
    
    func showResults(with stringTag: String?, sortFilter: SortFilter? = nil) {
        if let stringTag = stringTag {
            SearchManager.main.appendSearch(SearchManager.SearchHistory(timeStamp: Date(), searchString: stringTag, sortFilter: currentSortFilter))
            tableView.reloadData()
        }
        if let sortFilter = sortFilter {
            currentSortFilter = sortFilter
        }
        
        let listVC = UIStoryboard(name: ListCollectionVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: ListCollectionVC.storyboardID) as! ListCollectionVC
        let dataSource = ListCollectionVM(result: ListResult(), sortFilter: currentSortFilter)
        listVC.dataSource = dataSource
        #if DEBUG
            print("getting search: \(String(describing: stringTag))")
        #endif
        
        listVC.getNewResult(withTags: dataSource.tags(from: stringTag))
        
        navigationController?.delegate = listVC
        listVC.isFirstListCollectionVC = false
        listVC.shouldHideNavigationBar = false
        
        navigationController?.pushViewController(listVC, animated: true)
        listVC.title = stringTag
    }
}

extension SearchHomeVC: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
    }
    
    func searchControllerDidSelect(item: String) {
        searchController.searchBar.text = item
        searchController.dismiss(animated: true, completion: {
            
        })
    }
}

extension SearchHomeVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true, completion: {
            self.showResults(with: searchBar.text?.lowercased().trimmingCharacters(in: .whitespaces))
        })
        
    }
}

// Mark: - Popover Presentation Delegate

extension SearchHomeVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// Mark: - ListCollectionFilterVCDelegate

extension SearchHomeVC: ListCollectionFilterVCDelegate {
    func filterDidApply(filter: SortFilter) {
        currentSortFilter = filter
    }
    
    func currentFilter() -> SortFilter? {
        return currentSortFilter
    }
    
    
}

// Mark: - SearchHomeVCTableHeaderView

class SearchHomeVCTableHeaderView: UIView {
    
    static let storyboardID = "searchHomeVCTableHeaderView"
    var delegate: SearchHomeVC?
    
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var mainButton: UIButton!
    
    @IBAction func mainButtonDidClick(_ sender: UIButton) {
        SearchManager.main.clearHistory()
        delegate?.tableView.reloadData()
    }
    
    func setupLayout() {
        backgroundColor = Theme.colors().background
        mainLabel.textColor = Theme.colors().labelText
        mainButton.tintColor = Theme.colors().labelLink
    }
    
    func setupContent(delegate: SearchHomeVC?) {
        self.delegate = delegate
        mainLabel.text = "Recent"
        mainButton.titleLabel?.text = "Clear"
    }
    
}










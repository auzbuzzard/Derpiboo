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
    
    // Mark: - VC Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchSuggestionsVC = storyboard?.instantiateViewController(withIdentifier: SearchSuggestionsVC.storyboardID) as! SearchSuggestionsVC
        setupSearchField()
    }
    
    private func setupSearchField() {
        searchController = UISearchController(searchResultsController: searchSuggestionsVC)
        searchController.searchResultsUpdater = searchSuggestionsVC
        searchController.dimsBackgroundDuringPresentation = true
        //searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.barStyle = .black
        searchController.searchBar.keyboardAppearance = .dark
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textField?.textColor = Theme.colors().labelText
        textField?.placeholder = "Search for Images"
        
        navigationItem.titleView = searchController.searchBar
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // Mark: - Methods
    
    func showResults(with stringTag: String?) {
        let listVC = storyboard?.instantiateViewController(withIdentifier: ListCollectionVC.storyboardID) as! ListCollectionVC
        let dataSource = ListCollectionVM(result: ListResult())
        listVC.dataSource = dataSource
        #if DEBUG
            print("getting search: \(String(describing: stringTag))")
        #endif
        
        listVC.getNewResult(withTags: dataSource.tags(from: stringTag))
        
        navigationController?.delegate = listVC
        listVC.isFirstListCollectionVC = true
        listVC.shouldHideNavigationBar = false
        
        navigationController?.pushViewController(listVC, animated: true)
        listVC.title = stringTag
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearchResultVC" {
            if let vc = segue.destination as? SearchResultVC, let sender = sender as? UISearchBar  {
                vc.searchString = sender.text
            }
        }
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
            self.showResults(with: searchBar.text)
        })
        
    }
}

extension SearchHomeVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController == self {
            navigationController.setNavigationBarHidden(true, animated: animated)
            if navigationController.hidesBarsOnSwipe == true {
                navigationController.hidesBarsOnSwipe = false
            }
        } else {
            navigationController.setNavigationBarHidden(false, animated: animated)
            if let _ = viewController as? ListCollectionVC {
                navigationController.hidesBarsOnSwipe = true
                
            } else {
                if navigationController.hidesBarsOnSwipe == true {
                    navigationController.hidesBarsOnSwipe = false
                }
            }
        }
    }
}

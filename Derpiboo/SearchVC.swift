 //
 //  SearchVC.swift
 //  E621
 //
 //  Created by Austin Chau on 10/8/16.
 //  Copyright © 2016 Austin Chau. All rights reserved.
 //
 
 import UIKit
 
 class SearchVC: UIViewController {
    
    var searchController: UISearchController!
    var searchBar: UISearchBar { get { return searchController.searchBar } }
    var searchSuggestionsVC: SearchSuggestionsVC!
    
    @IBOutlet weak var searchViewHolder: UIView!
    
    @IBAction func segueWithSearch(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Theme.colors().background
        
        navigationController?.delegate = self
        
        searchSuggestionsVC = storyboard?.instantiateViewController(withIdentifier: "searchSuggestionsVC") as! SearchSuggestionsVC
        
        searchController = UISearchController(searchResultsController: searchSuggestionsVC)
        
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = Theme.colors().labelText
        
        searchController.delegate = self
        
        searchBar.delegate = self
        
        searchController.searchResultsUpdater = searchSuggestionsVC
        
        searchViewHolder.addSubview(searchBar)
        searchBar.searchBarStyle = .minimal
        searchBar.keyboardAppearance = .dark
        searchBar.returnKeyType = .search
        
        definesPresentationContext = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchVC.useE621ModeDidChange), name: Notification.Name.init(rawValue: Preferences.useE621Mode.rawValue), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame.size.width = self.view.frame.size.width
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearchResultVC" {
            if let vc = segue.destination as? SearchResultVC, let sender = sender as? UISearchBar  {
                vc.searchString = sender.text
            }
            
        }
    }
    
    
    
    //    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    //        searchController.searchBar.sizeToFit()
    //        searchController.searchBar.frame.size.width = size.width
    //    }
    //
    
    
    //Mark: Results
    
    var listVC: ListCollectionVC!
    var searchString: String?
    var correctedSearchString: String? {
        get {
            return searchString?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        }
    }
    
    func showResults() {
        
        listVC = storyboard?.instantiateViewController(withIdentifier: "listCollectionVC") as! ListCollectionVC
        listVC.delegate = self
        listVC.isFirstListVC = false
        
        //print(searchString)
        //print(correctedSearchString)
        
        navigationController?.pushViewController(listVC, animated: true)
        
        listVC.title = searchString
        
        listVC.collectionView?.collectionViewLayout.invalidateLayout()
        
    }
    
    func useE621ModeDidChange() {
        listVC.getNewResult()
    }
 }
 
 extension SearchVC: ListCollectionVCRequestDelegate {
    internal func vcShouldLoadImmediately() -> Bool {
        return true
    }
    
    func getResult(results: ListResult?, completion: @escaping (ListResult) -> Void) {
        let requester = ListRequester()
        requester.get(listOfType: .search, tags: correctedSearchString, result: results, completion: completion)
    }
 }

 
 extension SearchVC: UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchResultsController?.view.isHidden = false
        }
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        
    }
    
    func searchControllerDidSelect(item: String) {
        searchBar.text = item
        searchController.dismiss(animated: true, completion: {
            
        })
    }
    
 }
 
 extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true, completion: {
            
        })
        //UserDefaults.standard.set(searchBar.text, forKey: Store.searchHistory.rawValue)
        searchString = searchBar.text
        showResults()
    }
    
    
    
 }
 
 extension SearchVC: UINavigationControllerDelegate {
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

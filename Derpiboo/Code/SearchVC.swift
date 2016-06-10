//
//  FeaturedVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 1/29/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UISearchBarDelegate {
    
    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------
    
    var collectionVC: ResultsCollectionVC!
    
    var searchController: UISearchController?
    var searchActive : Bool = false
    
    // ------------------------------------
    // MARK: ViewController Life Cycle
    // ------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchBar()
        
        collectionVC = storyboard?.instantiateViewControllerWithIdentifier("ResultsCollectionVC") as! ResultsCollectionVC
        collectionVC.dataSource = Derpibooru.listInstance
        addChildViewController(collectionVC)
        view.addSubview(collectionVC.view)
        
        //collectionVC.loadNewImages("twilight sparkle")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------
    // MARK: - Search Bar
    // ------------------------------------
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        collectionVC.searchTerm = searchBar.text
        collectionVC.clearCollectionView()
        collectionVC.loadNewImages(searchBar.text)
    }
    
    
    // ------------------------------------
    // MARK: - Convenience Methods
    // ------------------------------------
    
    func setUpSearchBar() {
        self.searchController = UISearchController(searchResultsController:  nil)
        
        //self.searchController!.delegate = self
        self.searchController!.searchBar.delegate = self
        
        self.searchController!.hidesNavigationBarDuringPresentation = false
        self.searchController!.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController!.searchBar
        
        self.definesPresentationContext = true
    }

}

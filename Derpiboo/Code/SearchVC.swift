//
//  FeaturedVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 1/29/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class SearchVC: UIViewController {
    
    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------
    
    var collectionVC: ResultsCollectionVC!
    
    var searchController: UISearchController?
    
    // ------------------------------------
    // MARK: ViewController Life Cycle
    // ------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchBar()
        
        collectionVC = storyboard?.instantiateViewControllerWithIdentifier("ResultsCollectionVC") as! ResultsCollectionVC
        addChildViewController(collectionVC)
        view.addSubview(collectionVC.view)
        
        collectionVC.loadNewImages("twilight sparkle")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------
    // MARK: - Convenience Methods
    // ------------------------------------
    
    func setUpSearchBar() {
        self.searchController = UISearchController(searchResultsController:  nil)
        
        //self.searchController!.delegate = self
        //self.searchController!.searchBar.delegate = self
        
        self.searchController!.hidesNavigationBarDuringPresentation = false
        self.searchController!.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController!.searchBar
        
        self.definesPresentationContext = true
    }

}

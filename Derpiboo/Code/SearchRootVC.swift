//
//  SearchRootVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/17/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class SearchRootVC: UIViewController {
    
    var imageGrid: ImageGridVC!
    
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageGrid = storyboard?.instantiateViewControllerWithIdentifier("ImageGridVC") as! ImageGridVC
        
        imageGrid.derpibooru = Derpibooru()
        imageGrid.imageResultsType = DBClientImages.ImageResultsType.Search
        
        addChildViewController(imageGrid)
        view.addSubview(imageGrid.view)
        
        searchController = UISearchController(searchResultsController: nil)
        
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        navigationItem.titleView = searchController.searchBar

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchRootVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let text = searchBar.text {
            imageGrid.derpibooru.searchTerm = text
            print(imageGrid.derpibooru.searchTerm)
            imageGrid.clearImageGrid()
            imageGrid.loadNewImages()
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        imageGrid.shouldLoadMoreImage = false
        imageGrid.clearImageGrid()
    }
}

extension SearchRootVC: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
}
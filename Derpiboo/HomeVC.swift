//
//  HomeVC.swift
//  E621
//
//  Created by Austin Chau on 10/7/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class HomeVC: UINavigationController {
    
    var listVC: ListCollectionVC!
    
    // Mark: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        instantiateVC()
        
        //navigationItem.title = "Derpibooru"
    }
    
    func instantiateVC() {
        listVC = UIStoryboard(name: ListCollectionVC.storyboardName, bundle: nil).instantiateViewController(withIdentifier: ListCollectionVC.storyboardID) as! ListCollectionVC
        
        listVC.isFirstListCollectionVC = true
        listVC.shouldHideNavigationBar = true
        
        listVC.title = "Derpibooru"
        
        listVC.dataSource = ListCollectionVM(result: ListResult())
        listVC.getNewResult()
        
        setViewControllers([listVC], animated: false)
    }
}



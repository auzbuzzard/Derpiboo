//
//  FeaturedVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 1/29/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class FeaturedVC: UIViewController {
    
    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------
    
    var collectionVC: ResultsCollectionVC!
    
    // ------------------------------------
    // MARK: ViewController Life Cycle
    // ------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionVC = storyboard?.instantiateViewControllerWithIdentifier("ResultsCollectionVC") as! ResultsCollectionVC
        collectionVC.dataSource = Derpibooru.defaultInstance
        addChildViewController(collectionVC)
        view.addSubview(collectionVC.view)
        
        collectionVC.loadNewImages(nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

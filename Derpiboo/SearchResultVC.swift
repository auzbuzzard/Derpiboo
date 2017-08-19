
//
//  SearchResultVC.swift
//  e926
//
//  Created by Austin Chau on 10/9/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class SearchResultVC: UIViewController {
    
    var listVC: ListCollectionVC!
    
    var searchString: String?
    var correctedSearchString: String? {
        get {
            return searchString?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //NotificationCenter.default.addObserver(self, selector: #selector(HomeVC.useE621ModeDidChange), name: Notification.Name.init(rawValue: Preferences.useE621Mode.rawValue), object: nil)
        
        instantiateVC()
        
        self.title = searchString
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
        navigationController?.hidesBarsOnSwipe = false
        super.viewWillDisappear(animated)
        
    }
    
    func instantiateVC() {
        listVC = storyboard?.instantiateViewController(withIdentifier: ListCollectionVC.storyboardID) as! ListCollectionVC
        
        setupVC(vc: listVC)
        
        navigationController?.pushViewController(listVC, animated: false)
        
        listVC.collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func setupVC(vc: ListCollectionVC) {
        //vc.delegate = self
        //vc.collectionView?.contentInset = UIEdgeInsetsMake(64, 0, 40, 0)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



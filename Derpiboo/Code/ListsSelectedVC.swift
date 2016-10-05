//
//  ListsSelectedVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/24/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ListsSelectedVC: UIViewController {
    
    var imageGrid: ImageGridVC!
    
    var selectedTableIndex: Int!
    var selectedListName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageGrid = storyboard?.instantiateViewController(withIdentifier: "ImageGridVC") as! ImageGridVC
        
        imageGrid.derpibooru = Derpibooru()
        imageGrid.imageResultsType = DBClientImages.ImageResultsType.List
        imageGrid.listName = selectedListName
        
        addChildViewController(imageGrid)
        view.addSubview(imageGrid.view)
        
        imageGrid.loadNewImages()
        
        
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

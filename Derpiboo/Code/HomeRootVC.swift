//
//  HomeRootVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/11/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class HomeRootVC: UIViewController {
    
    var imageGrid: ImageGridVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageGrid = storyboard?.instantiateViewControllerWithIdentifier("ImageGridVC") as! ImageGridVC
        
        imageGrid.derpibooru = Derpibooru()
        
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

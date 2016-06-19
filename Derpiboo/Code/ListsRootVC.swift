//
//  ListsRootVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ListsRootVC: UIViewController {
    
    var imageGroupTable: ImageGroupTableVC!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageGroupTable = storyboard?.instantiateViewControllerWithIdentifier("ImageGroupTableVC") as! ImageGroupTableVC
        
        addChildViewController(imageGroupTable)
        view.addSubview(imageGroupTable.view)
        
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

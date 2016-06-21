//
//  InfoPaneRootVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/20/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class InfoPaneRootVC: UIViewController {
    
    var dbImage: DBImage!
    
    var detailsVC: InfoPaneDetailsVC!
    var commentsVC: InfoPaneCommentsVC!

    @IBAction func infoPaneTabValueChanged(sender: UISegmentedControl) {
        
        getInfoPaneChildView(sender.selectedSegmentIndex)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getInfoPaneChildView(0)

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
    
    // private methods
    
    private func getInfoPaneChildView(index: Int) {
        if index == 0 { //details
            
            if detailsVC == nil {
                detailsVC = storyboard?.instantiateViewControllerWithIdentifier("InfoPaneDetailsVC") as! InfoPaneDetailsVC
                detailsVC.dbImage = dbImage
            }
            
            //detailsVC.tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            
            detailsVC.automaticallyAdjustsScrollViewInsets = true
            
            view.addSubview(detailsVC.view)
            addChildViewController(detailsVC)
            detailsVC.didMoveToParentViewController(self)
            
        } else if index == 1 { //comments
            
            if commentsVC == nil {
                commentsVC = storyboard?.instantiateViewControllerWithIdentifier("InfoPaneCommentsVC") as! InfoPaneCommentsVC
                commentsVC.dbImage = dbImage
            }
            
            commentsVC.automaticallyAdjustsScrollViewInsets = true
            
            view.addSubview(commentsVC.view)
            addChildViewController(commentsVC)
            commentsVC.didMoveToParentViewController(self)
            
        }
    }
    

}

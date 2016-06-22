//
//  InfoPaneRootVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/20/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class InfoPaneRootVC: UIViewController {
    
    var derpibooru: Derpibooru!
    var dbImage: DBImage!
    
    var detailsVC: InfoPaneDetailsVC!
    var commentsVC: InfoPaneCommentsVC!
    
    var contentInset: UIEdgeInsets!

    @IBAction func infoPaneTabValueChanged(sender: UISegmentedControl) {
        
        getInfoPaneChildView(sender.selectedSegmentIndex)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //print("layoutguide: \(topLayoutGuide.length)")
        
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
            if commentsVC != nil {
                commentsVC.view.removeFromSuperview()
                commentsVC.removeFromParentViewController()
            }
            
            //detailsVC.tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            
            //detailsVC.automaticallyAdjustsScrollViewInsets = true
            
            addChildViewController(detailsVC)
            detailsVC.didMoveToParentViewController(self)
            view.addSubview(detailsVC.view)
            view.layoutSubviews()
            
            //print("contentInset: \(contentInset)")
            
        } else if index == 1 { //comments
            
            if commentsVC == nil {
                commentsVC = storyboard?.instantiateViewControllerWithIdentifier("InfoPaneCommentsVC") as! InfoPaneCommentsVC
                commentsVC.derpibooru = derpibooru
                commentsVC.dbImage = dbImage
            }
            if detailsVC != nil {
                detailsVC.view.removeFromSuperview()
                detailsVC.removeFromParentViewController()
            }
            
            //commentsVC.automaticallyAdjustsScrollViewInsets = true
            commentsVC.tableView.contentInset = contentInset
            
            addChildViewController(commentsVC)
            commentsVC.didMoveToParentViewController(self)
            view.addSubview(commentsVC.view)
            view.layoutSubviews()
            
        }
    }
    

}

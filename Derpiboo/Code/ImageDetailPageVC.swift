//
//  ImageDetailPageVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 12/25/15.
//  Copyright © 2015 Austin Chau. All rights reserved.
//

import UIKit

class ImageDetailPageVC: UIViewController, UIPageViewControllerDataSource {
    
    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------
    
    var pageViewController: UIPageViewController!
    
    var imageArrayIndexFromSegue: Int!
    
    // ------------------------------------
    // MARK: DerpibooruDataSource
    // ------------------------------------
    
    var derpibooruDataSource: DerpibooruDataSource!
    var imageArray: [DBImage] { get { return derpibooruDataSource.imageArray } }
    let numberOfSections = 1
    
    // ------------------------------------
    // MARK: ViewController Life Cycle
    // ------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("ImageDetailPageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        
        let startVC = viewControllerAtIndex(imageArrayIndexFromSegue) as ImageDetailVC
        let VCs = [startVC]
        
        pageViewController.setViewControllers(VCs, direction: .Forward, animated: true, completion: nil)
        
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------
    // MARK: UIPageViewControllerDataSource
    // ------------------------------------
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ImageDetailVC
        var index = vc.currentImageArrayIndex as Int
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ImageDetailVC
        var index = vc.currentImageArrayIndex as Int
        
        if index == 0 || index == NSNotFound {
            return nil
        }
        
        index++
        
        return viewControllerAtIndex(index)
    }
    
    // ------------------------------------
    // MARK: Convenience Method
    // ------------------------------------
    
    func viewControllerAtIndex(index: Int) -> ImageDetailVC {                if imageArray.count == 0 || index >= imageArray.count {
            return ImageDetailVC()
        }
        
        let vc = storyboard?.instantiateViewControllerWithIdentifier("ImageDetailVC") as! ImageDetailVC
        
        vc.derpibooruDataSource = self.derpibooruDataSource
        vc.currentImageArrayIndex = index
        
        return vc
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

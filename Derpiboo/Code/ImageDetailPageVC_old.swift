////
////  ImageDetailPageVC.swift
////  Derpiboo
////
////  Created by Austin Chau on 12/25/15.
////  Copyright © 2015 Austin Chau. All rights reserved.
////
//
//import UIKit
//import SafariServices
//
//class ImageDetailPageVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, SFSafariViewControllerDelegate {
//    
//    // ------------------------------------
//    // MARK: Variables / Stores
//    // ------------------------------------
//    
//    @IBAction func openInSafari(sender: UIBarButtonItem) {
//        let url = NSURL(string: "https://derpibooru.org/\(imageArray[curentArrayIndex].id_number)")
//        let svc = SFSafariViewController(URL: url!, entersReaderIfAvailable: true)
//        svc.delegate = self
//        self.presentViewController(svc, animated: true, completion: nil)
//    }
//    
//    //SFSafariView
//    
//    func safariViewControllerDidFinish(controller: SFSafariViewController)
//    {
//        controller.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    
//    var pageViewController: UIPageViewController!
//    
//    var imageArrayIndexFromSegue: Int!
//    var curentArrayIndex: Int = 0
//    
//    // ------------------------------------
//    // MARK: DerpibooruDataSource
//    // ------------------------------------
//    
//    var derpibooruDataSource: DerpibooruDataSource!
//    var imageArray: [DBImage] { get { return derpibooruDataSource.imageArray } }
//    let numberOfSections = 1
//    
//    // ------------------------------------
//    // MARK: ViewController Life Cycle
//    // ------------------------------------
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("ImageDetailPageViewController") as! UIPageViewController
//        pageViewController.dataSource = self
//        pageViewController.delegate = self
//        pageViewController.view.backgroundColor = UIColor.blackColor()
//        
//        let startVC = viewControllerAtIndex(imageArrayIndexFromSegue) as ImageDetailVC
//        let VCs = [startVC]
//        
//        curentArrayIndex = imageArrayIndexFromSegue
//        
//        pageViewController.setViewControllers(VCs, direction: .Forward, animated: true, completion: nil)
//        
//        addChildViewController(pageViewController)
//        view.addSubview(pageViewController.view)
//        pageViewController.didMoveToParentViewController(self)
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        navigationController?.hidesBarsOnTap = true
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        if navigationController?.navigationBarHidden == true {
//            navigationController?.setNavigationBarHidden(false, animated: false)
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        parentViewController?.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    // ------------------------------------
//    // MARK: Navigation Controller
//    // ------------------------------------
//    
//    override func prefersStatusBarHidden() -> Bool {
//        return navigationController?.navigationBarHidden == true
//    }
//    
//    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
//        return UIStatusBarAnimation.Slide
//    }
//    
//    // ------------------------------------
//    // MARK: UIPageViewControllerDataSource
//    // ------------------------------------
//    
//    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
//        
//        let vc = viewController as! ImageDetailVC
//        var index = vc.currentImageArrayIndex as Int
//        
//        if index == 0 || index == NSNotFound {
//            return nil
//        }
//        
//        index -= 1
//        
//        return viewControllerAtIndex(index)
//    }
//    
//    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
//        
//        let vc = viewController as! ImageDetailVC
//        var index = vc.currentImageArrayIndex as Int
//        
//        if index == imageArray.count - 1 || index == NSNotFound {
//            return nil
//        }
//        
//        index += 1
//        
//        return viewControllerAtIndex(index)
//    }
//    
//    // ------------------------------------
//    // MARK: UIPageViewControllerDelegate
//    // ------------------------------------
//    
//    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
//        if let pageItemController = pendingViewControllers[0] as? ImageDetailVC {
//            curentArrayIndex = pageItemController.currentImageArrayIndex
//        }
//    }
//    
//    // ------------------------------------
//    // MARK: Convenience Method
//    // ------------------------------------
//    
//    func viewControllerAtIndex(index: Int) -> ImageDetailVC {
//        if imageArray.count == 0 || index >= imageArray.count {
//            return ImageDetailVC()
//        }
//        
//        let vc = storyboard?.instantiateViewControllerWithIdentifier("ImageDetailVC") as! ImageDetailVC
//        
//        vc.derpibooruDataSource = self.derpibooruDataSource
//        vc.currentImageArrayIndex = index
//        
//        return vc
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}

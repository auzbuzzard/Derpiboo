//
//  ImageDetailPageVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//
import UIKit
import SafariServices

class ImageDetailPageVC: UIViewController, SFSafariViewControllerDelegate {
    
    var derpibooru: Derpibooru!
    
    var pageController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    
    var imageIndexFromSegue: Int!
    var currentImageIndex: Int!
    
    @IBAction func returnToImageDetailPageVC(segue: UIStoryboardSegue) {
        
    }
    
    
    @IBOutlet var singleTapGR: UITapGestureRecognizer!
    @IBAction func singleTapDetected(sender: UITapGestureRecognizer) {
        if let navbar = navigationController?.navigationBar {
            if navbar.hidden == true {
                navigationController?.setToolbarHidden(true, animated: true)
            } else {
                navigationController?.setToolbarHidden(false, animated: true)
            }
        }
    }
    @IBAction func optionsButtonClicked(sender: UIBarButtonItem) {
    }
    
    @IBAction func openInSafari(sender: UIBarButtonItem) {
        let url = NSURL(string: "https://derpibooru.org/\(derpibooru.images[currentImageIndex].id_number)")
        let svc = SFSafariViewController(URL: url!, entersReaderIfAvailable: true)
        svc.delegate = self
        self.presentViewController(svc, animated: true, completion: nil)
    }
    
    
    //SFSafariView
    
    func safariViewControllerDidFinish(controller: SFSafariViewController)
    {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false

        pageController.dataSource = self
        pageController.delegate = self
        
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.didMoveToParentViewController(self)
        
        guard let startVC = getViewController(atIndex: imageIndexFromSegue) else { print("ImageDetailPage: viewController(atIndex) return nil."); return }
        let vcs = [startVC]
        
        currentImageIndex = imageIndexFromSegue
        
        pageController.setViewControllers(vcs, direction: .Forward, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = true
        
        if navigationController?.navigationBar.hidden == false {
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //print("page swipe: \(navigationController?.hidesBarsOnSwipe), tap: \(navigationController?.hidesBarsOnTap)")
        
        
        if navigationController?.toolbar.hidden == false {
            navigationController?.setToolbarHidden(true, animated: true)
        }
        
        navigationController?.hidesBarsOnTap = false
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.setToolbarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Slide
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "imageDetailModal" {
            let navVC = segue.destinationViewController as! UINavigationController
            let vc = navVC.viewControllers.first as! InfoPaneRootVC
            
            vc.dbImage = derpibooru.images[currentImageIndex]
        }
        
    }
    
    //Convenience
    
    func getViewController(atIndex index: Int) -> ImageDetailVC? {
        if derpibooru.images.count != 0 && index < derpibooru.images.count {
            let vc = storyboard?.instantiateViewControllerWithIdentifier("ImageDetailVC") as! ImageDetailVC
            
            vc.derpibooru = derpibooru
            vc.imageIndex = index
            
            return vc
        } else {
            return nil
        }
    }
}

extension ImageDetailPageVC: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ImageDetailVC
        if vc.imageIndex == 0 { return nil }
        return getViewController(atIndex: vc.imageIndex - 1)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ImageDetailVC
        if vc.imageIndex == derpibooru.images.count - 1 { return nil }
        return getViewController(atIndex: vc.imageIndex + 1)
    }
}

extension ImageDetailPageVC: UIPageViewControllerDelegate {
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers[0] as? ImageDetailVC {
            currentImageIndex = vc.imageIndex
        }
    }
}

extension ImageDetailPageVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === singleTapGR && otherGestureRecognizer == navigationController?.barHideOnTapGestureRecognizer {
            print("true")
            return true
        } else {
            print("false")
            return false
        }
    }
}
//
//  ImageDetailPageVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//
import UIKit
import SafariServices

class ImageDetailPageVC: UIPageViewController, SFSafariViewControllerDelegate {
    
    var derpibooru: Derpibooru!
    
    var imageIndexFromSegue: Int!
    var currentImageIndex: Int!
    
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

        dataSource = self
        delegate = self
        
        guard let startVC = getViewController(atIndex: imageIndexFromSegue) else { print("ImageDetailPage: viewController(atIndex) return nil."); return }
        let vcs = [startVC]
        
        currentImageIndex = imageIndexFromSegue
        
        setViewControllers(vcs, direction: .Forward, animated: true, completion: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        //print("page swipe: \(navigationController?.hidesBarsOnSwipe), tap: \(navigationController?.hidesBarsOnTap)")
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.hidesBarsOnTap = false
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
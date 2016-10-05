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
    
    var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    var imageIndexFromSegue: Int!
    var currentImageIndex: Int!
    
    @IBAction func returnToImageDetailPageVC(_ segue: UIStoryboardSegue) {
        
    }
    
    
    @IBOutlet var singleTapGR: UITapGestureRecognizer!
    @IBAction func singleTapDetected(_ sender: UITapGestureRecognizer) {
        if let navbar = navigationController?.navigationBar {
            if navbar.isHidden == true {
                navigationController?.setToolbarHidden(true, animated: true)
            } else {
                navigationController?.setToolbarHidden(false, animated: true)
            }
        }
    }
    @IBAction func optionsButtonClicked(_ sender: UIBarButtonItem) {
        let alertC = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        alertC.addAction(UIAlertAction(title: "Share Image", style: .default, handler: {
            alert in
            self.shareImageViaActivityView()
        }))
        alertC.addAction(UIAlertAction(title: "Share Derpibooru Link", style: .default, handler: {
            alert in
            self.shareLinkViaActivityView()
        }))
        alertC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            alert in
            alertC.dismiss(animated: true, completion: nil)
        }))
        present(alertC, animated: true, completion: nil)
    }
    
    @IBAction func openInSafari(_ sender: UIBarButtonItem) {
        let url = URL(string: "https://derpibooru.org/\(derpibooru.images[currentImageIndex].id)")
        let svc = SFSafariViewController(url: url!, entersReaderIfAvailable: true)
        svc.delegate = self
        self.present(svc, animated: true, completion: nil)
    }
    
    
    //SFSafariView
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController)
    {
        controller.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false

        pageController.dataSource = self
        pageController.delegate = self
        
        addChildViewController(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
        
        guard let startVC = getViewController(atIndex: imageIndexFromSegue) else { print("ImageDetailPage: viewController(atIndex) return nil."); return }
        let vcs = [startVC]
        
        currentImageIndex = imageIndexFromSegue
        
        pageController.setViewControllers(vcs, direction: .forward, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = true
        
        if navigationController?.navigationBar.isHidden == false {
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //print("page swipe: \(navigationController?.hidesBarsOnSwipe), tap: \(navigationController?.hidesBarsOnTap)")
        
        
        if navigationController?.toolbar.isHidden == false {
            navigationController?.setToolbarHidden(true, animated: true)
        }
        
        navigationController?.hidesBarsOnTap = false
        //navigationController?.hidesBarsOnSwipe = true
        navigationController?.setToolbarHidden(true, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "imageDetailModal" {
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.viewControllers.first as! InfoPaneRootVC
            
            vc.derpibooru = derpibooru
            vc.dbImage = derpibooru.images[currentImageIndex]
        }
        
    }
    
    //Convenience
    
    func getViewController(atIndex index: Int) -> ImageDetailVC? {
        if derpibooru.images.count != 0 && index < derpibooru.images.count {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ImageDetailVC") as! ImageDetailVC
            
            vc.derpibooru = derpibooru
            vc.imageIndex = index
            
            return vc
        } else {
            return nil
        }
    }
    
    fileprivate func shareImageViaActivityView() {
        if let image = derpibooru.images[currentImageIndex].largeImage {
            print("ok")
            let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            present(activity, animated: true, completion: nil)
        }
    }
    
    fileprivate func shareLinkViaActivityView() {
        if let url = URL(string: "https://derpibooru.org/\(derpibooru.images[currentImageIndex].id)") {
            print("ok")
            let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activity, animated: true, completion: nil)
        }
    }
    
    // Cleaning
    
}

extension ImageDetailPageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ImageDetailVC
        if vc.imageIndex == 0 { return nil }
        return getViewController(atIndex: vc.imageIndex - 1)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ImageDetailVC
        if vc.imageIndex == derpibooru.images.count - 1 { return nil }
        return getViewController(atIndex: vc.imageIndex + 1)
    }
}

extension ImageDetailPageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let vc = pendingViewControllers[0] as? ImageDetailVC {
            currentImageIndex = vc.imageIndex
        }
    }
}

extension ImageDetailPageVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === singleTapGR && otherGestureRecognizer == navigationController?.barHideOnTapGestureRecognizer {
            print("true")
            return true
        } else {
            print("false")
            return false
        }
    }
}

//
//  ImageZoomVC.swift
//  e926
//
//  Created by Austin Chau on 10/9/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageZoomVC: UIViewController {

    var mainImageView: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var imageResult: ImageResult!
    var isFileImage = false
    var isFullScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainImageView = UIImageView(frame: CGRect.zero)
        
        
        mainScrollView.decelerationRate = UIScrollViewDecelerationRateFast
        
        mainScrollView.delegate = self
        
        mainScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mainScrollView.addSubview(mainImageView)
        //print(mainScrollView.contentInset)
        
        setupGestureRecognizer()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let image = imageResult.getImage(ofSize: .full, callback: { image, id, error in
            DispatchQueue.main.async {
                self.isFileImage = true
                self.setImageView(image: image)
                //self.mainImageView.image = image
            }
        }) {
            DispatchQueue.main.async {
                self.isFileImage = true
                self.setImageView(image: image)
                //self.mainImageView.image = image
            }
        } else {
            if let image = imageResult.getImage(ofSize: .large, callback: { image, id, error in
                if !self.isFileImage {
                    DispatchQueue.main.async {
                        self.setImageView(image: image)
                        //self.mainImageView.image = image
                    }
                }
                
            }) {
                DispatchQueue.main.async {
                    self.setImageView(image: image)
                    //self.mainImageView.image = image
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustPadding()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.notifyWhenInteractionEnds({ context in
            
        })
        self.mainScrollView.contentSize = self.mainImageView.frame.size
        adjustPadding()
    }
    
    func adjustPadding() {
        let imageViewSize = mainImageView.frame.size
        let scrollViewSize = mainScrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        mainScrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        //print(mainScrollView.contentInset)
    }
    
    func setImageView(image: UIImage?) {
        mainImageView.image = image
        if let image = image {
            mainImageView.frame.size = image.size
        }
        //mainImageView.sizeToFit()
        mainScrollView.contentSize = mainImageView.bounds.size
        
        setZoomScale()
        //adjustPadding()
    }
    
    func setZoomScale() {
        let imageViewSize = mainImageView.bounds.size
        let scrollViewSize = mainScrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        let minimumZoomScale = min(widthScale, heightScale)
        let maximumZoomScale = minimumZoomScale * 6.0
        
        if minimumZoomScale != CGFloat.infinity && maximumZoomScale != CGFloat.infinity {
        mainScrollView.minimumZoomScale = minimumZoomScale
        //print(minimumZoomScale, maximumZoomScale)
        //print(mainScrollView.maximumZoomScale)
        mainScrollView.maximumZoomScale = maximumZoomScale
            mainScrollView.zoomScale = minimumZoomScale
        }
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(ImageZoomVC.handleDoubleTap(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        mainScrollView.addGestureRecognizer(doubleTap)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ImageZoomVC.handleSingleTap(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        mainScrollView.addGestureRecognizer(singleTap)
        
        
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (mainScrollView.zoomScale > mainScrollView.minimumZoomScale) {
            mainScrollView.setZoomScale(mainScrollView.minimumZoomScale, animated: true)
        } else {
            mainScrollView.setZoomScale(mainScrollView.maximumZoomScale * 0.4, animated: true)
//            if let bool = navigationController?.isNavigationBarHidden {
//                navigationController?.setNavigationBarHidden(!bool, animated: true)
//            }
//            if let bool = tabBarController?.isTabBarVisible() {
//                tabBarController?.setTabBarVisible(visible: !bool, animated: true)
//            }
        }
        adjustPadding()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        
        switchBetweenFullScreen(animated: true)
        
    }
    
    func switchBetweenFullScreen(animated: Bool) {
        let duration = animated ? 0.3 : 0.1
        if isFullScreen {
            UIView.animate(withDuration: duration, animations: {
                self.navigationController?.navigationBar.alpha = 1
                self.tabBarController?.tabBar.alpha = 1
                self.view.backgroundColor = UIColor.white
            }, completion: { success in
                if success {
                    self.isFullScreen = !self.isFullScreen
                }
            })
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.navigationController?.navigationBar.alpha = 0
                self.tabBarController?.tabBar.alpha = 0
                self.view.backgroundColor = UIColor.black
            }, completion: { success in
                if success {
                    self.isFullScreen = !self.isFullScreen
                }
            })
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetailVC" {
            let vc = segue.destination as! ImageDetailVC
            vc.imageResult = imageResult
        }
    }
    

}

extension ImageZoomVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainImageView
    }
}

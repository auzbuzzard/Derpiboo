//
//  ImageZoomVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 10/9/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit
import PromiseKit

/// Class that control the fullscreen image viewer view
class ImageZoomVC: UIViewController {

    // Mark: - Properties
    var mainImageView: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var imageResult: ImageResult!
    fileprivate(set) var isFileImage = false
    fileprivate(set) var isFullScreen = false
    
    // Mark: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.colors().background
        mainImageView = UIImageView(frame: CGRect.zero)
        setupScrollView()
        setupGestureRecognizer()
        
        loadImage()
        loadExtraMetadata()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustPadding()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.notifyWhenInteractionEnds({ context in
            //self.view.invalidateIntrinsicContentSize()
            self.mainScrollView.contentSize = self.mainImageView.frame.size
        })
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale(thenZoomOut: true)
    }
    
    // Mark: - Data Loading
    
    func loadImage() {
        _ = imageResult.image(ofSize: .large).then { image -> Void in
            if !self.isFileImage {
                self.setImageView(image: image, withZoom: true)
            }
        }
        _ = imageResult.image(ofSize: .full).then { image -> Void in
            self.setImageView(image: image, withZoom: false)
            self.isFileImage = true
        }
    }
    
    func loadExtraMetadata() {
        
    }
    
    // Mark: - Scroll View and ImageView Constraints
    
    func setupScrollView() {
        mainScrollView.decelerationRate = UIScrollViewDecelerationRateFast
        mainScrollView.delegate = self
        mainScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainScrollView.addSubview(mainImageView)
    }

    func adjustPadding() {
        let imageViewSize = mainImageView.frame.size
        let scrollViewSize = mainScrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        mainScrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setImageView(image: UIImage?, withZoom: Bool) {
        mainImageView.image = image

        if withZoom {
            adjustViewSizes(thenZoomOut: true)
        }
    }
    func adjustViewSizes(thenZoomOut zoomOut: Bool) {
        mainImageView.sizeToFit()
        mainScrollView.contentSize = mainImageView.bounds.size
        setZoomScale(thenZoomOut: zoomOut)
    }
    
    func setZoomScale(thenZoomOut zoomOut: Bool) {
        let imageViewSize = mainImageView.bounds.size
        let scrollViewSize = mainScrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        let minimumZoomScale = min(widthScale, heightScale)
        let maximumZoomScale = minimumZoomScale * 6.0
        
        if minimumZoomScale != CGFloat.infinity && maximumZoomScale != CGFloat.infinity {
            mainScrollView.minimumZoomScale = minimumZoomScale
            mainScrollView.maximumZoomScale = maximumZoomScale
            if zoomOut {
                mainScrollView.zoomScale = minimumZoomScale
            }
        }
    }
    
    // Mark: - Gesture Recognizers
    
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
            print("NO")
        } else {
            switchTo(fullScreen: true, animated: true, withExtraAnimation: {
                self.mainScrollView.setZoomScale(self.mainScrollView.maximumZoomScale * 0.4, animated: true)
            }, completion: { })
            print("YES")
        }
        adjustPadding()
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        switchBetweenFullScreen(animated: true, withExtraAnimation: { }, completion: { })
    }
    
    // Mark: - Fullscreen aka Hiding the Bars
    
    func switchBetweenFullScreen(animated: Bool, withExtraAnimation: @escaping () -> Void, completion: @escaping () -> Void) {
        switchTo(fullScreen: !isFullScreen, animated: animated, withExtraAnimation: withExtraAnimation, completion: completion)
    }
    
    func switchTo(fullScreen switchToFullScreen: Bool, animated: Bool, withExtraAnimation: @escaping () -> Void, completion: @escaping () -> Void) {
        let duration = animated ? 0.3 : 0.0
        if switchToFullScreen {
            UIView.animate(withDuration: duration, animations: {
                UIApplication.shared.isStatusBarHidden = true
                self.navigationController?.setNavigationBarHidden(true, animated: false)
                self.navigationController?.navigationBar.alpha = 0
                self.tabBarController?.tabBar.isHidden = true
                self.tabBarController?.tabBar.alpha = 0
                self.view.backgroundColor = UIColor.black
                withExtraAnimation()
            }, completion: { success in
                if success {
                    self.isFullScreen = true
                    completion()
                }
            })
        } else {
            UIView.animate(withDuration: duration, animations: {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController?.navigationBar.alpha = 1
                self.tabBarController?.tabBar.isHidden = false
                self.tabBarController?.tabBar.alpha = 1
                self.view.backgroundColor = Theme.colors().background
                UIApplication.shared.isStatusBarHidden = false
                withExtraAnimation()
            }, completion: { success in
                if success {
                    self.isFullScreen = false
                    completion()
                }
            })
        }
    }
    
    // Mark: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageDetailVC" {
            let vc = segue.destination as! ImageDetailVC
            vc.imageResult = imageResult
        }
    }
}


// MARK: - Mandatory UIScrollViewDelegate to enable zooming
extension ImageZoomVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainImageView
    }
}

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
        
        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        view.backgroundColor = Theme.colors().background
        mainImageView = UIImageView(frame: CGRect.zero)
        if imageResult.metadata.original_format_enum == .webm || imageResult.metadata.original_format_enum == .swf {
            let filetypeWarningView = UIImageView(image: imageResult.metadata.original_format_enum == .webm ? #imageLiteral(resourceName: "webm") : #imageLiteral(resourceName: "swf"))
            view.addSubview(filetypeWarningView)
            filetypeWarningView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints([
                NSLayoutConstraint(item: filetypeWarningView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: filetypeWarningView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: filetypeWarningView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: view.bounds.width * 0.3),
                NSLayoutConstraint(item: filetypeWarningView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.bounds.width * 0.3)
                ])
        } else {
            setupScrollView()
            setupGestureRecognizer()
            
            loadImage()
        }
        loadExtraMetadata()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.layoutSubviews()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustPadding()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        /*coordinator.notifyWhenInteractionEnds({ context in
            //self.view.invalidateIntrinsicContentSize()
            self.mainScrollView.contentSize = self.mainImageView.frame.size
        })*/
        view.layoutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale(thenZoomOut: true)
    }
    
    // Mark: - Data Loading
    
    func loadImage() {
        _ = imageResult.imageData(for: .large).then { data -> Void in
            if !self.isFileImage {
                self.setImageView(data: data, withZoom: true)
            }
        }
        _ = imageResult.imageData(for: .full).then { data -> Void in
            self.setImageView(data: data, withZoom: false)
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
    
    func setImageView(data: Data?, withZoom: Bool) {
        #if DEBUG
            print("[Verbose] imageDetailView for (\(imageResult.id)) is trying to set image.")
        #endif
        guard let data = data else { mainImageView.image = nil; return }
        guard let image = UIImage(data: data) else { print("Image could not be casted into UIImage."); return }
        mainImageView.image = image
        if imageResult.metadata.original_format_enum == .gif {
            mainImageView.image = image
            mainImageView.animate(withGIFData: data)
        }

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
            //print("NO")
        } else {
            switchTo(fullScreen: true, animated: true, withExtraAnimation: {
                self.mainScrollView.setZoomScale(self.mainScrollView.maximumZoomScale * 0.4, animated: true)
            }, completion: { })
            //print("YES")
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
        
        UIView.animate(withDuration: duration, animations: {
            UIApplication.shared.isStatusBarHidden = switchToFullScreen
            self.navigationController?.setNavigationBarHidden(switchToFullScreen, animated: false)
            self.navigationController?.navigationBar.alpha = switchToFullScreen ? 0 : 1
            self.tabBarController?.tabBar.isHidden = switchToFullScreen
            self.tabBarController?.tabBar.alpha = switchToFullScreen ? 0 : 1
            self.view.backgroundColor = switchToFullScreen ? UIColor.black : Theme.colors().background
            withExtraAnimation()
        }, completion: { success in
            if success {
                self.isFullScreen = switchToFullScreen
                completion()
            }
        })
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

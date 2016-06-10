//
//  ImageDetailVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 12/25/15.
//  Copyright © 2015 Austin Chau. All rights reserved.
//

import UIKit

class ImageDetailVC: UIViewController, DBImageFullImageDelegate {
    
    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------
    
    var currentImageArrayIndex: Int!
    var currentDBmage: DBImage { get { return imageArray[currentImageArrayIndex] } }
    
    // ------------------------------------
    // MARK: IBAction / IBOutlet
    // ------------------------------------
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBAction func scrollViewDoubleTapped(sender: UITapGestureRecognizer) {
        navigationController?.barHideOnTapGestureRecognizer.requireGestureRecognizerToFail(sender)
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.minimumZoomScale * 3, animated: true)
        }
    }
    
    // ------------------------------------
    // MARK: DerpibooruDataSource
    // ------------------------------------
    
    var derpibooruDataSource: DerpibooruDataSource!
    var imageArray: [DBImage] { get { return derpibooruDataSource.imageArray } }
    
    // ------------------------------------
    // MARK: ViewController Life Cycle
    // ------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        
        currentDBmage.fullImageDelegate = self
        
        if currentDBmage.fullImage == nil {
            currentDBmage.downloadFullImage()
            updateImageView(currentDBmage.thumbnail)
        } else {
            updateImageView(currentDBmage.fullImage)
            scrollViewDidZoom(scrollView)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        //updateImageView(currentDBmage.thumbnail)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------
    // MARK: - DBImageFullImageDelegate
    // ------------------------------------
    
    func fullImageDidFinishDownloading(dbImage: DBImage) {
        dispatch_async(dispatch_get_main_queue()) {
            self.updateImageView(self.currentDBmage.fullImage)
            self.scrollViewDidZoom(self.scrollView)
        }
    }
    
    // ------------------------------------
    // MARK: - Convenience Method
    // ------------------------------------
    
    private func updateImageView(image: UIImage?) {
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        imageView.image = image
        setZoomScale(image!)
    }
    
    func setZoomScale(image: UIImage?) {
        var imageViewSize: CGSize
        if image != nil {
            let imageSize = CGSize(width: image!.size.width, height: image!.size.height)
            imageViewSize = imageSize
        } else {
            imageViewSize = imageView.bounds.size
        }

        scrollView.contentSize = imageViewSize
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        let minimumZoomScale = min(widthScale, heightScale)
        //print(minimumZoomScale)
        
        scrollView.minimumZoomScale = minimumZoomScale
        scrollView.maximumZoomScale = minimumZoomScale * 6
        scrollView.zoomScale = minimumZoomScale
        
        scrollView.layoutIfNeeded()
    }
    
    // ------------------------------------
    // MARK: - Scroll View Delegate
    // ------------------------------------
    
    override func viewWillLayoutSubviews() {
        setZoomScale(nil)
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

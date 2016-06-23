//
//  ImageDetailVC.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/18/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageDetailVC: UIViewController {

    // ------------------------------------
    // MARK: Variables / Stores
    // ------------------------------------

    var imageIndex: Int!
    var dbImage: DBImage { get { return derpibooru.images[imageIndex] } }
    
    var urlSession: NSURLSession!
    var expectedContentLength = 0
    var buffer:NSMutableData = NSMutableData()
    
    let imageSizeType: DBImage.ImageSizeType = .large

    // ------------------------------------
    // MARK: IBAction / IBOutlet
    // ------------------------------------

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var progressView: UIProgressView!
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

    var derpibooru: Derpibooru!

    // ------------------------------------
    // MARK: ViewController Life Cycle
    // ------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        progressView.hidden = true
        
        navigationController?.hidesBarsOnTap = true
        
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast

        if dbImage.largeImage == nil {
            dbImage.downloadImage(ofSizeType: imageSizeType, urlSession: urlSession, useCustomDelegate: true, completion: nil)
            updateImageView(dbImage.thumbImage)
        } else {
            updateImageView(dbImage.largeImage)
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
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        setZoomScale(imageView.image)
        scrollViewDidZoom(scrollView)
    }
    
    // ------------------------------------
    // MARK: - Convenience Method
    // ------------------------------------

    private func updateImageView(image: UIImage?) {
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        imageView.image = image
        setZoomScale(imageView.image)
    }

    func setZoomScale(image: UIImage?) {
        var imageViewSize: CGSize
        if image != nil {
            let imageSize = CGSize(width: image!.size.width, height: image!.size.height)
            imageViewSize = imageSize
        } else {
            imageViewSize = imageView.bounds.size
        }
        if imageViewSize == CGSizeZero { return }
        
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

extension ImageDetailVC: NSURLSessionDelegate, NSURLSessionDataDelegate {
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        progressView.progress = 1.0
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            guard let image = UIImage(data: self.buffer) else { print("data to image error"); return }
            self.dbImage.setImage(ofSizeType: self.imageSizeType, image: image)
            dispatch_async(dispatch_get_main_queue()) {
                self.updateImageView(self.dbImage.getImage(ofSizeType: self.imageSizeType))
                self.scrollViewDidZoom(self.scrollView)
            }
        }

        
        updateImageView(dbImage.largeImage)
        //scrollViewDidZoom(scrollView)
        progressView.hidden = true
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveResponse response: NSURLResponse, completionHandler: (NSURLSessionResponseDisposition) -> Void) {
        expectedContentLength = Int(response.expectedContentLength)
        completionHandler(NSURLSessionResponseDisposition.Allow)
    }
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        
        buffer.appendData(data)
        progressView.hidden = false
        
        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
        progressView.progress =  percentageDownloaded
    }
}

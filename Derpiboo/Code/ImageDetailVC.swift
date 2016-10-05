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
    
    var urlSession: Foundation.URLSession!
    var expectedContentLength = 0
    var buffer:NSMutableData = NSMutableData()
    
    let imageSizeType: DBImage.ImageSizeType = .large
    
    // ------------------------------------
    // MARK: IBAction / IBOutlet
    // ------------------------------------
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBAction func scrollViewDoubleTapped(_ sender: UITapGestureRecognizer) {
        navigationController?.barHideOnTapGestureRecognizer.require(toFail: sender)
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.zoomToPoint(sender.location(ofTouch: 0, in: view), withScale: scrollView.minimumZoomScale, animated: true)
            //scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.zoomToPoint(sender.location(ofTouch: 0, in: view), withScale: scrollView.minimumZoomScale * 3, animated: true)
            //scrollView.setZoomScale(scrollView.minimumZoomScale * 3, animated: true)
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
        
        urlSession = Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        
        progressView.isHidden = true
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        //updateImageView(currentDBmage.thumbnail)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setZoomScale(imageView.image)
        scrollViewDidZoom(scrollView)
    }
    
    // ------------------------------------
    // MARK: - Convenience Method
    // ------------------------------------
    
    fileprivate func updateImageView(_ image: UIImage?) {
        scrollView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        imageView.image = image
        setZoomScale(imageView.image)
    }
    
    func setZoomScale(_ image: UIImage?) {
        var imageViewSize: CGSize
        if image != nil {
            let imageSize = CGSize(width: image!.size.width, height: image!.size.height)
            imageViewSize = imageSize
        } else {
            imageViewSize = imageView.bounds.size
        }
        if imageViewSize == CGSize.zero { return }
        
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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func viewForZoomingInScrollView(_ scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

extension ImageDetailVC: URLSessionDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        progressView.progress = 1.0
        DispatchQueue.global(qos: DispatchQoS.QoSClass.utility).async {
            guard let image = UIImage(data: self.buffer as Data) else { print("data to image error"); return }
            self.dbImage.setImage(ofSizeType: self.imageSizeType, image: image)
            DispatchQueue.main.async {
                self.updateImageView(self.dbImage.getImage(ofSizeType: self.imageSizeType))
                self.scrollViewDidZoom(self.scrollView)
            }
        }
        
        
        updateImageView(self.dbImage.largeImage)
        //scrollViewDidZoom(scrollView)
        progressView.isHidden = true
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        expectedContentLength = Int(response.expectedContentLength)
        completionHandler(Foundation.URLSession.ResponseDisposition.allow)
    }
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        buffer.append(data)
        progressView.isHidden = false
        
        let percentageDownloaded = Float(buffer.length) / Float(expectedContentLength)
        progressView.progress =  percentageDownloaded
    }
}

extension UIScrollView {
    
    func zoomToPoint(_ zoomPoint: CGPoint, withScale scale: CGFloat, animated: Bool) {
        //Normalize current content size back to content scale of 1.0f
        let contentSize = CGSize(width: (self.contentSize.width / self.zoomScale), height: (self.contentSize.height / self.zoomScale))
        
        //translate the zoom point to relative to the content rect
        let newZoomPoint = CGPoint(x: (zoomPoint.x / self.bounds.size.width) * contentSize.width, y: (zoomPoint.y / self.bounds.size.height) * contentSize.height)
        
        //derive the size of the region to zoom to
        let zoomSize = CGSize(width: self.bounds.size.width / scale, height: self.bounds.size.height / scale)
        
        //offset the zoom rect so the actual zoom point is in the middle of the rectangle
        let zoomRect = CGRect(x: newZoomPoint.x - zoomSize.width / 2.0,
                              y: newZoomPoint.y - zoomSize.height / 2.0,
                              width: zoomSize.width,
                              height: zoomSize.height)
        
        //apply the resize
        self.zoom(to: zoomRect, animated: animated)
    }
    
}

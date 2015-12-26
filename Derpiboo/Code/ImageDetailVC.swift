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
        
        if currentDBmage.fullImage != nil {
            updateImageView(currentDBmage.fullImage)
        } else {
            currentDBmage.downloadFullImage()
            updateImageView(currentDBmage.thumbnail)
        }
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
        }
    }
    
    // ------------------------------------
    // MARK: - Convenience Method
    // ------------------------------------
    
    private func updateImageView(image: UIImage?) {
        imageView.image = image
        updateZoom()
    }
    
    // Zoom to show as much image as possible unless image is smaller than the scroll view
    private func updateZoom() {
        if let image = imageView.image {
            let minZoom = min(scrollView.bounds.size.width / image.size.width,
                scrollView.bounds.size.height / image.size.height)
            
            scrollView.minimumZoomScale = minZoom
            scrollView.zoomScale = minZoom
        }
    }
}

//
//  ImageGridFlowLayout.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/11/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class ImageGridFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

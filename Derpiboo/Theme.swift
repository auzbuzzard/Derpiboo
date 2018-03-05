//
//  Theme.swift
//  E621
//
//  Created by Austin Chau on 10/8/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

enum Colors: Int {
    case light = 1, dark
    
    var background: UIColor {
        switch self {
        case .light:
            return UIColor.white
        case .dark:
            return UIColor(red: 30/255, green: 34/255, blue: 41/255, alpha: 1) //#1e2229
        }
    }
    
    var background2: UIColor {
        switch self {
        case .light:
            return UIColor(red: 215/255, green: 266/255, blue: 234/255, alpha: 1)
        case .dark:
            return UIColor(red: 61/255, green: 70/255, blue: 87/255, alpha: 1) //#3d4657
        }
    }
    
    var background_header: UIColor {
        switch self {
        case .light:
            return UIColor(red: 215/255, green: 255/255, blue: 255/255, alpha: 1)
        case .dark:
            return UIColor(red: 40/255, green: 67/255, blue: 113/255, alpha: 1) //#284371
        }
    }
    
    var highlight: UIColor {
        switch self {
        case .light:
            return UIColor(red: 110/255, green: 174/255, blue: 222/255, alpha: 1) //#6eaede
        case .dark:
            return UIColor(red: 77/255, green: 103/255, blue: 154/255, alpha: 1) //#4d679a
        }
    }
    var highlight2: UIColor {
        switch self {
        case .light:
            return UIColor(red: 81/255, green: 158/255, blue: 215/255, alpha: 1) //#519ed7
        case .dark:
            return UIColor(red: 65/255, green: 87/255, blue: 130/255, alpha: 1) //#415782
        }
    }
    
    var labelText: UIColor {
        switch self {
        case .light:
            return UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1) //#333
        case .dark:
            return UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1) //#e0e0e0
        }
    }
    var labelLink: UIColor {
        switch self {
        case .light:
            return UIColor(red: 87/255, green: 164/255, blue: 219/255, alpha: 1) //#57a4db
        case .dark:
            return UIColor(red: 74/255, green: 144/255, blue: 217/255, alpha: 1) //#4a90d9
        }
    }
    
    var fav: UIColor {
        switch self {
        case .light:
            return UIColor(red: 77/255, green: 70/255, blue: 27/255, alpha: 1) //#c4b246
        case .dark:
            return UIColor(red: 163/255, green: 147/255, blue: 52/255, alpha: 1) //#a39334
        }
    }
    var upv: UIColor {
        switch self {
        case .light:
            return UIColor(red: 103/255, green: 175/255, blue: 43/255, alpha: 1) //#67af2b
        case .dark:
            return UIColor(red: 91/255, green: 155/255, blue: 38/255, alpha: 1) //#5b9b26
        }
    }
    var dnv: UIColor {
        switch self {
        case .light:
            return UIColor(red: 81/255, green: 0, blue: 0, alpha: 1) //#cf0001
        case .dark:
            return UIColor(red: 218/255, green: 52/255, blue: 18/255, alpha: 1) //#da3412
        }
    }
    var comment: UIColor {
        switch self {
        case .light:
            return UIColor(red: 57/255, green: 45/255, blue: 82/255, alpha: 1) //#9273d0
        case .dark:
            return UIColor(red: 176/255, green: 153/255, blue: 211/255, alpha: 1) //#b099dd
        }
    }
    
    // Tags
    
}

struct Theme {
    static func colors() -> Colors {
        return .dark
    }
    
    static func apply(_ theme: Colors) {
        
        if theme == .dark {
            UINavigationBar.appearance().barStyle = UIBarStyle.black
            UIApplication.shared.statusBarStyle = .lightContent
        }
        
        // Status Bar
        //UIApplication.shared.statusBarView?.backgroundColor = background_header_color
        
        // Tab Bar
            // Remove top gradient line
        UITabBar.appearance().layer.borderWidth = 0.0
        UITabBar.appearance().clipsToBounds = true
        UITabBar.appearance().tintColor = theme.labelLink
        UITabBar.appearance().barTintColor = theme.background
        
        // Nav Bar
        //UINavigationBar.appearance().setBackgroundImage(background_header_imageColor, for: .default)
        UINavigationBar.appearance().barTintColor = theme.background_header
        UINavigationBar.appearance().tintColor = theme.labelText
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : Theme.colors().labelText]
        
        // Table View
        UITableView.appearance().backgroundColor = theme.background
        UITableViewCell.appearance().backgroundColor = theme.background
        
        // Collection View
        UICollectionView.appearance().backgroundColor = theme.background
        
        // Tool Bar
        UIToolbar.appearance().barTintColor = theme.background_header
        UIToolbar.appearance().tintColor = theme.labelText
        
        // UI Buttons
        UILabel.appearance().textColor = theme.labelText
        UITextField.appearance().tintColor = theme.labelLink
        UITextView.appearance().tintColor = theme.labelLink
        
        UISwitch.appearance().tintColor = theme.highlight
        
    }
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

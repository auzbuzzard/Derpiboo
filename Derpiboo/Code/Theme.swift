//
//  Theme.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/22/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

enum DBTheme: Int {
    case Light = 1, Dark
    
    var background: UIColor {
        switch self {
        case Light:
            return UIColor.whiteColor()
        case Dark:
            return UIColor(red: 56/255, green: 58/255, blue: 59/255, alpha: 1) //#383a3b
        }
    }
    var background2: UIColor {
        switch self {
        case Light:
            return UIColor(red: 215/255, green: 266/255, blue: 234/255, alpha: 1)
        case Dark:
            return UIColor(red: 86/255, green: 89/255, blue: 90/255, alpha: 1) //#56595a
        }
    }
    
    var highlight: UIColor {
        switch self {
        case Light:
            return UIColor(red: 110/255, green: 174/255, blue: 222/255, alpha: 1) //#6eaede
        case Dark:
            return UIColor(red: 77/255, green: 103/255, blue: 154/255, alpha: 1) //#4d679a
        }
    }
    var highlight2: UIColor {
        switch self {
        case Light:
            return UIColor(red: 81/255, green: 158/255, blue: 215/255, alpha: 1) //#519ed7
        case Dark:
            return UIColor(red: 65/255, green: 87/255, blue: 130/255, alpha: 1) //#415782
        }
    }
    
    var labelText: UIColor {
        switch self {
        case Light:
            return UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1) //#333
        case Dark:
            return UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1) //#e0e0e0
        }
    }
    var labelLink: UIColor {
        switch self {
        case Light:
            return UIColor(red: 87/255, green: 164/255, blue: 219/255, alpha: 1) //#57a4db
        case Dark:
            return UIColor(red: 74/255, green: 144/255, blue: 217/255, alpha: 1) //#4a90d9
        }
    }
    
    var fav: UIColor {
        switch self {
        case Light:
            return UIColor(red: 77/255, green: 70/255, blue: 27/255, alpha: 1) //#c4b246
        case Dark:
            return UIColor(red: 163/255, green: 147/255, blue: 52/255, alpha: 1) //#a39334
        }
    }
    var upv: UIColor {
        switch self {
        case Light:
            return UIColor(red: 103/255, green: 175/255, blue: 43/255, alpha: 1) //#67af2b
        case Dark:
            return UIColor(red: 91/255, green: 155/255, blue: 38/255, alpha: 1) //#5b9b26
        }
    }
    var dnv: UIColor {
        switch self {
        case Light:
            return UIColor(red: 81/255, green: 0, blue: 0, alpha: 1) //#cf0001
        case Dark:
            return UIColor(red: 218/255, green: 52/255, blue: 18/255, alpha: 1) //#da3412
        }
    }
    var comment: UIColor {
        switch self {
        case Light:
            return UIColor(red: 57/255, green: 45/255, blue: 82/255, alpha: 1) //#9273d0
        case Dark:
            return UIColor(red: 176/255, green: 153/255, blue: 211/255, alpha: 1) //#b099dd
        }
    }
}

struct Theme {
    static let themeKey = "SelectedTheme"
    
    static func current() -> DBTheme {
        if let storedTheme = NSUserDefaults.standardUserDefaults().valueForKey(themeKey)?.integerValue {
            return DBTheme(rawValue: storedTheme)!
        } else {
            return .Dark
        }
    }
    static func apply(Theme theme: DBTheme) {
        NSUserDefaults.standardUserDefaults().setValue(theme.rawValue, forKey: themeKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        let sharedApplication = UIApplication.sharedApplication()
        sharedApplication.delegate?.window??.tintColor = theme.highlight
        
        if theme == .Dark {
            UINavigationBar.appearance().barStyle = UIBarStyle.Black
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        }
        
        UINavigationBar.appearance().barTintColor = theme.highlight2
        UINavigationBar.appearance().tintColor = theme.labelText
        UITabBar.appearance().barTintColor = theme.highlight2
        UITabBar.appearance().tintColor = theme.labelText
        UIToolbar.appearance().barTintColor = theme.highlight2
        UIToolbar.appearance().tintColor = theme.labelText
        
        UILabel.appearance().textColor = theme.labelText
        UITextField.appearance().tintColor = theme.labelLink
        UITextView.appearance().tintColor = theme.labelLink
        
        UITableView.appearance().backgroundColor = theme.background
        UITableViewCell.appearance().backgroundColor = theme.background2
        
        UISwitch.appearance().tintColor = theme.highlight
    }
}



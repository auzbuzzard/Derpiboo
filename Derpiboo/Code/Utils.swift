//
//  Utils.swift
//  Derpiboo
//
//  Created by Austin Chau on 6/11/16.
//  Copyright © 2016 Austin Chau. All rights reserved.
//

import UIKit

class Utils {
    
    enum ColorTheme {
        case Light
        case Dark
    }
    
    static var colorTheme: ColorTheme = .Dark
    
    static func color() -> Color.Type {
        switch colorTheme {
        case .Light:
            return ColorLight.self
        case .Dark:
            return ColorDark.self
        }
    }
    
    private struct ColorLight: Color {
        static let background = UIColor.whiteColor()
        static let background2 = UIColor(red: 215/255, green: 266/255, blue: 234/255, alpha: 1)
        
        static let highlight = UIColor(red: 110/255, green: 174/255, blue: 222/255, alpha: 1) //#6eaede
        static let highlight2 = UIColor(red: 81/255, green: 158/255, blue: 215/255, alpha: 1) //#519ed7
        
        static let labelText = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1) //#333
        
        static let fav = UIColor(red: 77/255, green: 70/255, blue: 27/255, alpha: 1) //#c4b246
        static let upv = UIColor(red: 103/255, green: 175/255, blue: 43/255, alpha: 1) //#67af2b
        static let dnv = UIColor(red: 81/255, green: 0, blue: 0, alpha: 1) //#cf0001
        static let comment = UIColor(red: 57/255, green: 45/255, blue: 82/255, alpha: 1) //#9273d0
    }
    
    private struct ColorDark: Color {
        static let background = UIColor(red: 56/255, green: 58/255, blue: 59/255, alpha: 1) //#383a3b
        static let background2 = UIColor(red: 86/255, green: 89/255, blue: 90/255, alpha: 1) //#56595a
        
        static let highlight = UIColor(red: 77/255, green: 103/255, blue: 154/255, alpha: 1) //#4d679a
        static let highlight2 = UIColor(red: 65/255, green: 87/255, blue: 130/255, alpha: 1) //#415782
        
        static let labelText = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1) //#e0e0e0
        
        static let fav = UIColor(red: 163/255, green: 147/255, blue: 52/255, alpha: 1) //#a39334
        static let upv = UIColor(red: 91/255, green: 155/255, blue: 38/255, alpha: 1) //#5b9b26
        static let dnv = UIColor(red: 218/255, green: 52/255, blue: 18/255, alpha: 1) //#da3412
        static let comment = UIColor(red: 176/255, green: 153/255, blue: 211/255, alpha: 1) //#b099dd
    }
    
}

protocol Color {
    static var background: UIColor { get }
    static var background2: UIColor { get }
    
    static var highlight: UIColor { get }
    static var highlight2: UIColor { get }
    static var labelText: UIColor { get }
    
    static var fav: UIColor { get }
    static var upv: UIColor { get }
    static var dnv: UIColor { get }
    static var comment: UIColor { get }
}
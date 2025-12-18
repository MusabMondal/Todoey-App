//
//  ColorHex.swift
//  Todoey
//
//  Created by Musab Mondal on 2025-12-18.
//  Copyright © 2025 App Brewery. All rights reserved.
//

import Foundation

import UIKit

// MARK: - Random Hex Color
func randomHexColor() -> String {
    return String(format: "#%06X", Int.random(in: 0...0xFFFFFF))
}

// MARK: - UIColor from Hex
extension UIColor {

    convenience init?(hex: String, alpha: CGFloat = 1.0) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)

        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        guard hexString.count == 6,
              let rgbValue = UInt64(hexString, radix: 16) else {
            return nil
        }

        let red   = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8)  / 255.0
        let blue  = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
    /// Returns either black or white depending on which has better contrast
    func contrastTextColor() -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        // Convert to relative luminance (WCAG formula)
        func adjust(_ c: CGFloat) -> CGFloat {
            return c <= 0.03928 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }

        let luminance =
            0.2126 * adjust(r) +
            0.7152 * adjust(g) +
            0.0722 * adjust(b)

        // Threshold ~0.5 works well for UI
        return luminance > 0.5 ? .black : .white
    }
}

//
//  UIColor+Convenience.swift
//  DrawOnPic
//
//  Created by Paul Jarysta on 23/07/2016.
//  Copyright © 2016 Paul Jarysta. All rights reserved.
//

import UIKit

public extension UIColor {
	
	class func convertToUIColor(hex: Int, alpha: Double = 1.0) -> UIColor {
		let red = Double((hex & 0xFF0000) >> 16) / 255.0
		let green = Double((hex & 0xFF00) >> 8) / 255.0
		let blue = Double((hex & 0xFF)) / 255.0
		let color: UIColor = UIColor( red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha:CGFloat(alpha) )
		return color
	}
	
	class func lightGrey() -> UIColor {
		return UIColor.convertToUIColor(0xEFEFF4, alpha: 1.0)
	}
}

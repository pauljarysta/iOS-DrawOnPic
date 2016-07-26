//
//  DrawView.swift
//  DrawOnPic
//
//  Created by Paul Jarysta on 23/07/2016.
//  Copyright © 2016 Paul Jarysta. All rights reserved.
//

import UIKit

protocol DrawViewDelegate {
	func drawView(drawView: DrawView)
}

class DrawView: UIView {

	var delegate: DrawViewDelegate?
	var lineColor: UIColor?
	var lineWidth: CGFloat?
	var drawingArray: [AnyObject] = []
	var showDraw: Bool?
	var path: UIBezierPath?
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if (showDraw == true) {
			path = UIBezierPath()
			path!.lineWidth = lineWidth!
			path!.lineCapStyle = CGLineCap.Round
			path!.lineJoinStyle = CGLineJoin.Round
			
			let touch: UITouch = touches.first!
			path!.moveToPoint(touch.locationInView(self))
		}
	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if (showDraw == true) {
			let touch: UITouch = touches.first!
			path!.addLineToPoint(touch.locationInView(self))
			setNeedsDisplay()
		}
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if (showDraw == true) {

			let touch: UITouch = touches.first!
			path!.addLineToPoint(touch.locationInView(self))
			
			let dwo: DrawingObjects = DrawingObjects()
			dwo.setWidth(lineWidth!)
			
			var info: [NSObject : AnyObject] = [NSObject : AnyObject]()
			info["penColor"] = lineColor
			info["path"] = path
			info["others"] = dwo
			
			self.drawingArray.append(info)
			
			setNeedsDisplay()
			self.delegate?.drawView(self)
		}
	}
	
	override func drawRect(rect: CGRect) {
		lineColor!.set()
		if let path = path {
			path.stroke()
		}
	}
	
	func clearDrawView() {
		path!.removeAllPoints()
		setNeedsDisplay()
	}
}


class DrawingObjects: AnyObject {
	
	var lineWidth: CGFloat?
	
	func setWidth(width: CGFloat) {
		lineWidth = width
	}
	
	func getWidth() -> CGFloat {
		return lineWidth!
	}
}

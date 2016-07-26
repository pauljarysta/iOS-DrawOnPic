//
//  ViewController.swift
//  DrawOnPic
//
//  Created by Paul Jarysta on 23/07/2016.
//  Copyright © 2016 Paul Jarysta. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DrawViewDelegate {

	
	@IBOutlet weak var drawView: DrawView!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var bubbleView: UIImageView!
	
	@IBOutlet weak var undoBtn: UIButton!
	@IBOutlet weak var clearBtn: UIButton!
	@IBOutlet weak var drawBtn: UIButton!
	
	var saveImage: UIImage?
	var displayStatusBar: Bool?
	
	let mainBounds: CGRect = UIScreen.mainScreen().bounds
	
	let bubbleHeight: 			CGFloat = 50.0
	let penFrameWidth: 			CGFloat = 100.0
	let gradientViewWidth: 	CGFloat = 6.0
	let maxPenSize: 				CGFloat = 50.0
	let minPenSize: 				CGFloat = 5.0
	let lineWidth: 					CGFloat = 15.0
	let statusBarHeight: 		CGFloat = 0.0
	
	var gradientColorView: 	UIView?
	var gradientPenView: 		UIView?
	var gradientLayer: 			CAGradientLayer = CAGradientLayer()
	
	var circleLayerInner: 	CAShapeLayer = CAShapeLayer()
	var circleLayerOuter: 	CAShapeLayer = CAShapeLayer()
	
	var panGesture: 				UIPanGestureRecognizer?

	var pen: 							UIColor?
	var bInGradient: 				Bool?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		customView()

		imageView.image = UIImage(named: "background")!
		saveImage = UIImage(named: "background")!
		
		gradientPenView = UIView(frame: CGRectMake(mainBounds.size.width - penFrameWidth, 0, penFrameWidth, mainBounds.size.height))
				
		view!.addSubview(gradientPenView!)
		gradientPenView!.removeFromSuperview()
		
		gradientLayer.frame = CGRectMake(0, 0, gradientViewWidth, mainBounds.size.height - statusBarHeight)
		
		gradientLayer.colors = [
			(UIColor.blackColor().CGColor),
			(UIColor.whiteColor().CGColor),
			(UIColor.redColor().CGColor),
			(UIColor.brownColor().CGColor),
			(UIColor.orangeColor().CGColor),
			(UIColor.yellowColor().CGColor),
			(UIColor.greenColor().CGColor),
			(UIColor.cyanColor().CGColor),
			(UIColor.blueColor().CGColor),
			(UIColor.magentaColor().CGColor),
			(UIColor.purpleColor().CGColor)]
	
		gradientLayer.startPoint = CGPointMake(0.5, 0)
		gradientLayer.endPoint = CGPointMake(0.5, 1)
		
		gradientColorView = UIView(frame: CGRectMake(mainBounds.size.width, statusBarHeight, gradientViewWidth, mainBounds.size.height))

		panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.drag))
		gradientColorView!.addGestureRecognizer(panGesture!)
		gradientColorView!.hidden = true
		gradientColorView!.alpha = 0.0
		gradientColorView!.layer.addSublayer(gradientLayer)
		view!.addSubview(gradientColorView!)
		
		drawView.delegate = self
		drawView.showDraw = false
		drawView.lineWidth = lineWidth
		drawView.lineColor = UIColor.redColor()
		drawView.drawingArray = [AnyObject]()

		imageView.image = saveImage
		bInGradient = false
		displayStatusBar = true
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.applicationWillResign), name: UIApplicationWillResignActiveNotification, object: nil)
	}
	
	func customView() {
		drawBtn.layer.cornerRadius = 3.0
		undoBtn.layer.cornerRadius = 3.0
		undoBtn.hidden = true
		clearBtn.layer.cornerRadius = 3.0
		clearBtn.hidden = true
	}
	
	override func viewWillDisappear(animated: Bool) {
		circleLayerInner.removeFromSuperlayer()
		circleLayerOuter.removeFromSuperlayer()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	override func prefersStatusBarHidden() -> Bool {
		if let showStatusBar = displayStatusBar {
			return showStatusBar
		}
		return true
	}
	
	func applicationWillResign() {
		if (bInGradient == true) {
			gradientPenView!.removeFromSuperview()
			circleLayerInner.removeFromSuperlayer()
			circleLayerOuter.removeFromSuperlayer()
			bInGradient = false
		}
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		let p: CGPoint = touches.first!.locationInView(gradientColorView)
		let q: CGPoint = touches.first!.locationInView(gradientPenView)
		if CGRectContainsPoint(gradientLayer.frame, p) {
			bInGradient = true
			view!.addSubview(gradientPenView!)
			let yOffset: CGFloat = (p.y - gradientLayer.frame.origin.y)
			drawCircleView(p, withOffset: yOffset, withQ: q)
		}
		else {
			bInGradient = false
		}
	}
	
	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		if (bInGradient == true) {
			gradientPenView!.removeFromSuperview()
			let time: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 400000000)
			dispatch_after(time, dispatch_get_main_queue(), {() -> Void in
				self.circleLayerInner.removeFromSuperlayer()
				self.circleLayerOuter.removeFromSuperlayer()
			})
			UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 4.0, options: UIViewAnimationOptions.AllowUserInteraction , animations: {
				self.circleLayerInner.opacity = 0.0
				self.circleLayerOuter.opacity = 0.0
				}, completion: { finished in })
			bInGradient = false
		}
	}
	
	func drag(pan: UIPanGestureRecognizer) {
		if pan.state == .Ended {
			if (bInGradient == true) {
				gradientPenView!.removeFromSuperview()
				let time: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, 400000000)
				dispatch_after(time, dispatch_get_main_queue(), {() -> Void in
					self.circleLayerInner.removeFromSuperlayer()
					self.circleLayerOuter.removeFromSuperlayer()
				})
				UIView.animateWithDuration(0.4, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 4.0, options: UIViewAnimationOptions.AllowUserInteraction , animations: {
					self.circleLayerInner.opacity = 0.0
					self.circleLayerOuter.opacity = 0.0
					}, completion: { finished in })
				bInGradient = false
			}
			return
		}
		if (bInGradient == true) {
			let p: CGPoint = pan.locationInView(gradientColorView)
			let q: CGPoint = pan.locationInView(gradientPenView)
			let yOffset: CGFloat = (p.y - gradientLayer.frame.origin.y)
			drawCircleView(p, withOffset: yOffset, withQ: q)
		}
	}
	
	func drawCircleView(p: CGPoint, withOffset yOffset: CGFloat, withQ q: CGPoint) {

		var yOffSet: CGFloat?
		yOffSet = yOffset
		
		if yOffSet < 0.0 {
			yOffSet = 0.0
		}
		
		if yOffSet > gradientLayer.frame.size.height {
			yOffSet = gradientLayer.frame.size.height
		}
		
		let gap: CGFloat = (gradientLayer.frame.size.height / (CGFloat(gradientLayer.colors!.count - 1)))
		
		var index = Int(yOffSet!) / Int(gap)
		yOffSet = yOffSet! - (CGFloat(index) * gap)

		let color1: UIColor = UIColor(CGColor: (gradientLayer.colors![Int(index)] as! CGColorRef))
		
		if Int(index) > gradientLayer.colors!.count - 2 {
			index = gradientLayer.colors!.count - 2
		}
		
		let color2: UIColor = UIColor(CGColor: (gradientLayer.colors![Int(index) + 1] as! CGColorRef))
		var r1: CGFloat = 0
		var g1: CGFloat = 0
		var b1: CGFloat = 0
		var a1: CGFloat = 0
		var r2: CGFloat = 0
		var g2: CGFloat = 0
		var b2: CGFloat = 0
		var a2: CGFloat = 0
		
		color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
		color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

		pen = UIColor(red: (1 - (yOffSet! / gap)) * r1 + (yOffSet! / gap) * r2, green: (1 - (yOffSet! / gap)) * g1 + (yOffSet! / gap) * g2, blue: (1 - (yOffSet! / gap)) * b1 + (yOffSet! / gap) * b2, alpha: 1.0)
	
		var penSize: CGFloat = (gradientPenView!.bounds.size.width - q.x) / (gradientPenView!.bounds.size.width / maxPenSize)
		if penSize < minPenSize {
			penSize = minPenSize
		}
		else if penSize > maxPenSize {
			penSize = maxPenSize
		}
		
		circleLayerInner.removeFromSuperlayer()
		circleLayerOuter.removeFromSuperlayer()
		circleLayerOuter = CAShapeLayer()
		
		let screenWidth: CGFloat = bubbleView.bounds.size.width / 2.0
		let screenHeight: CGFloat = bubbleView.bounds.size.height / 2.0

		circleLayerOuter.bounds = CGRectMake(screenWidth - bubbleHeight / 2, screenHeight - bubbleHeight / 2, bubbleHeight, bubbleHeight)
		circleLayerOuter.position = CGPointMake(screenWidth, screenHeight)
		
		var path: UIBezierPath = UIBezierPath(ovalInRect: CGRectMake(screenWidth - bubbleHeight / 2, screenHeight - bubbleHeight / 2, bubbleHeight, bubbleHeight))
		
		circleLayerOuter.path = path.CGPath
		circleLayerOuter.strokeColor = pen!.CGColor
		circleLayerOuter.fillColor = UIColor.whiteColor().CGColor
		circleLayerOuter.lineWidth = 1.0

		bubbleView.layer.addSublayer(circleLayerOuter)

		circleLayerInner = CAShapeLayer()
		circleLayerInner.bounds = CGRectMake(screenWidth - bubbleHeight / 2, screenHeight - bubbleHeight / 2, bubbleHeight, bubbleHeight)
		circleLayerInner.position = CGPointMake(screenWidth, screenHeight)
		
		path = UIBezierPath(ovalInRect: CGRectMake(screenWidth - penSize / 2.0, screenHeight - penSize / 2.0, penSize, penSize))

		circleLayerInner.path = path.CGPath
		circleLayerInner.strokeColor = pen!.CGColor
		circleLayerInner.fillColor = pen!.CGColor
		circleLayerInner.lineWidth = 0.0
		
		bubbleView.layer.addSublayer(circleLayerInner)
		drawView.lineWidth = penSize
		
		drawView.lineColor = pen
	}
	
	func drawView(paintView: DrawView) {
		undoBtn.hidden = false
		clearBtn.hidden = false
		imageView.image = saveImage
		
		let bounds: CGRect = imageView.bounds
		UIGraphicsBeginImageContextWithOptions(bounds.size, false, imageView.contentScaleFactor)
		for subArray in drawView.drawingArray {
			let dwo: DrawingObjects = (subArray["others"] as! DrawingObjects)
			let lineWidth: CGFloat = dwo.getWidth()
			let lineColor: UIColor = (subArray["penColor"] as! UIColor)
			let path: UIBezierPath = (subArray["path"] as! UIBezierPath)
			let context: CGContextRef = UIGraphicsGetCurrentContext()!

			CGContextSetBlendMode(context, CGBlendMode.Copy)
			imageView.layer.renderInContext(context)
			
			CGContextClipToRect(context, bounds)
			CGContextSetLineWidth(context, lineWidth)
			CGContextSetLineCap(context, CGLineCap.Round)
			CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
			CGContextAddPath(context, path.CGPath)
			CGContextStrokePath(context)
			
			imageView.image = UIGraphicsGetImageFromCurrentImageContext()
			drawView.setNeedsDisplay()
		}
		UIGraphicsEndImageContext()
	}
	
	func mergePaintToBackgroundView(painted: CGRect) {
		imageView.image = saveImage
		
		let bounds: CGRect = imageView.bounds
		UIGraphicsBeginImageContextWithOptions(bounds.size, false, imageView.contentScaleFactor)
		let context: CGContextRef = UIGraphicsGetCurrentContext()!
		
		CGContextSetBlendMode(context, CGBlendMode.Copy)
		imageView.layer.renderInContext(context)
		
		CGContextClipToRect(context, painted)
		CGContextSetBlendMode(context, CGBlendMode.Normal)
		drawView.layer.renderInContext(context)
		
		drawView.clearDrawView()
		
		let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
		imageView.image = image
		UIGraphicsEndImageContext()
	}
	
	@IBAction func drawAction(sender: UIButton) {
	
		if (drawView.showDraw == true) {

			UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 4.0, options: UIViewAnimationOptions.AllowUserInteraction , animations: {
				self.gradientColorView!.frame = CGRectMake(self.mainBounds.size.width, self.statusBarHeight, self.gradientViewWidth, self.mainBounds.size.height)
				}, completion: { finished in })
			drawView.showDraw = false
			displayStatusBar = false
			performSelector(#selector(setNeedsStatusBarAppearanceUpdate))
		} else {
			UIView.animateWithDuration(0.2, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 4.0, options: UIViewAnimationOptions.AllowUserInteraction , animations: {
				self.gradientColorView!.frame = CGRectMake(self.mainBounds.size.width - self.gradientViewWidth, self.statusBarHeight, self.gradientViewWidth, self.mainBounds.size.height)
				self.gradientColorView!.alpha = 1.0
				self.gradientColorView!.hidden = false
				}, completion: { finished in })
			drawView.showDraw = true
			displayStatusBar = true
			performSelector(#selector(setNeedsStatusBarAppearanceUpdate))
		}
	}
	
	@IBAction func clearAction(sender: UIButton) {
		drawView.clearDrawView()
		drawView.drawingArray.removeAll()
		imageView.image = self.saveImage
		undoBtn.hidden = true
		clearBtn.hidden = true
	}
	
	@IBAction func undoAction(sender: UIButton) {
		
		if drawView.drawingArray.count < 2 {
			undoBtn.hidden = true
			clearBtn.hidden = true
			imageView.image = saveImage
			drawView.clearDrawView()
			drawView.drawingArray.removeAll()
		} else {
			undoBtn.hidden = false
			clearBtn.hidden = false
			drawView.clearDrawView()
			drawView.drawingArray.removeLast()
			imageView.image = saveImage
			
			let bounds: CGRect = imageView.bounds
			UIGraphicsBeginImageContextWithOptions(bounds.size, false, imageView.contentScaleFactor)
			
			for subArray in drawView.drawingArray {
				let dwo: DrawingObjects = (subArray["others"] as! DrawingObjects)
				let lineWidth: CGFloat = dwo.getWidth()
				let lineColor: UIColor = (subArray["penColor"] as! UIColor)
				let path: UIBezierPath = (subArray["path"] as! UIBezierPath)
				let context: CGContextRef = UIGraphicsGetCurrentContext()!

				CGContextSetBlendMode(context, CGBlendMode.Copy)
				imageView.layer.renderInContext(context)
				
				CGContextClipToRect(context, bounds)
				CGContextSetLineWidth(context, lineWidth)
				CGContextSetLineCap(context, CGLineCap.Round)
				CGContextSetStrokeColorWithColor(context, lineColor.CGColor)
				CGContextAddPath(context, path.CGPath)
				CGContextStrokePath(context)
				imageView.image = UIGraphicsGetImageFromCurrentImageContext()
			}
			UIGraphicsEndImageContext()
		}
	}
}


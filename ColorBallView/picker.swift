////
////  picker.swift
////  ColorBallView
////
////  Created by Iraniya Naynesh on 12/07/18.
////  Copyright © 2018 Iraniya. All rights reserved.
////
//
//import UIKit
//
//@IBDesignable
//
//class picker: UIControl {
//    
//    var trackWidth: CGFloat = 5
//    var pTrackWidth: CGFloat = 20
//    var thumbWidth: CGFloat = 25
//    
//    var BColorList = [#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor]
//    
//    //bottom slider
//    var bMinVal: Double = 30
//    var bMaxVal: Double = 150
//    
//    @IBInspectable var bProgressValue: Double = 150 {
//        didSet {
//            bTrackLayer.setNeedsDisplay()
//        }
//    }
//    var hueValues: (Int, Int, Int) = (255, 255, 255)
//    
//    let bTrackLayer = BottomSliderLayer()
//
//    // MARK: - Initialization
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        setUpColorBallView()
//    }
//    
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        
//        setUpColorBallView()
//    }
//    
//    func setUpColorBallView() {
//        
//        //Bottom Progress track
//        bTrackLayer.colorBallView = self
//        bTrackLayer.contentsScale = UIScreen.main.scale
//        layer.addSublayer(bTrackLayer)
//        
//        updateLayerFrames()
//    }
//    
//    func updateLayerFrames() {
//        
//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        
//        //frames for bottom progress tracking
//        let bTrackFrame: CGRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
//        bTrackLayer.frame = bTrackFrame
//        bTrackLayer.setNeedsDisplay()
//        
//        CATransaction.commit()
//    }
//    
//    //MARK: Touch methods
//    var previousLoaction = CGPoint()
//    
//    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        
//        previousLoaction = touch.location(in: self)
//        
//        if bTrackLayer.frame.contains(previousLoaction) {
//            bTrackLayer.highlighted = true
//            let angle = getAngle(fromPoint: previousLoaction)
//            return true
//        }
//        
//        return false
//    }
//    
//    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
//        
//        previousLoaction = touch.location(in: self)
//        
//        if bTrackLayer.highlighted {
//            getAngle(fromPoint: previousLoaction)
//            return true
//        }
//        resetLayers()
//        return false
//        
//    }
//    
//    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
//        resetLayers()
//    }
//    
//    open override func cancelTracking(with event: UIEvent?) {
//        resetLayers()
//    }
//    
//    func resetLayers() {
//        bTrackLayer.highlighted = false
//    }
//    
//    func getAngle(fromPoint point: CGPoint) -> Double {
//        
//        let newa
//        let cCenter = CGPoint(x: bounds.width/2, y: 0)
//        let angle: CGFloat = CGFloat(atan2(point.y - cCenter.y , -(point.x - cCenter.x))).radiansToDegrees
//        if bTrackLayer.highlighted {
//            if angle < 0 || angle > 180 { return }
//            let bottomNewAngle: Double = Double(180 - angle)
//            bProgressValue = boundValues(value: bottomNewAngle, toLowerValue: bMinVal, upperValue: bMaxVal)
//        }
//        
//        return
//    }
//    
//    func boundValues(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
//        return min(max(value, lowerValue), upperValue)
//    }
//    
//    func getPixelColorAtPoint(point:CGPoint) -> (red: Int, green: Int, blue:Int) {
//        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
//        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
//        context?.translateBy(x: -point.x, y: -point.y)
//        layer.render(in: context!)
//        pixel.deinitialize(count: 4)
//        return (Int(pixel[0]), Int(pixel[1]), Int(pixel[2]))
//    }
//}
//
//class BottomSliderLayer: CALayer {
//    
//    weak var colorBallView: picker?
//    var highlighted: Bool = false
//    var width: CGFloat { return bounds.width }
//    var height: CGFloat { return bounds.height }
//    
//    override func draw(in ctx: CGContext) {
//        if let colorBallView = colorBallView {
//            
//            let center = CGPoint(x: bounds.width / 2, y: 0)
//            let radius: CGFloat =  (bounds.width/2)
//            let startAngle: CGFloat = CGFloat(colorBallView.bMaxVal).degreesToRadians
//            let endAngle: CGFloat = CGFloat(colorBallView.bMinVal).degreesToRadians
//            
//            let centerRad  = radius - colorBallView.pTrackWidth/2
//            let startAngleRad = CGFloat(colorBallView.bMaxVal).degreesToRadians
//            let mindPointX = center.x + (centerRad * cos(startAngleRad))
//            let midPointY = center.y + (centerRad * sin(startAngleRad))
//            let midPoint: CGPoint = CGPoint(x: mindPointX, y: midPointY)
//            
//            let tCRad  = radius - colorBallView.pTrackWidth/2 + colorBallView.trackWidth/2
//            let endAngleRad = CGFloat(colorBallView.bMinVal).degreesToRadians
//            let endMidPointX = center.x + (tCRad * cos(endAngleRad))
//            let endMidPointY = center.y + (tCRad * sin(endAngleRad))
//            let endMidPoint: CGPoint = CGPoint(x: endMidPointX, y: endMidPointY)
//            
//            ctx.beginPath()
//            ctx.saveGState()
//            
//            //Track
//            let track = UIBezierPath()
//            track.addArc(withCenter: center, radius: radius - colorBallView.pTrackWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
//            track.addArc(withCenter: endMidPoint, radius: colorBallView.trackWidth/2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
//            track.addArc(withCenter: center, radius: radius - colorBallView.trackWidth , startAngle: endAngle, endAngle: startAngle, clockwise: true)
//            track.close()
//            ctx.setLineJoin(CGLineJoin.round)
//            ctx.setLineCap(CGLineCap.round)
//            ctx.addPath(track.cgPath)
//            ctx.clip()
//            ctx.fillPath()
//            
//            //Gradient fill
//            
//            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
//            
//            let colors = colorBallView.BColorList
//            let colorLocations: [CGFloat] = [0.0, 0.125, 0.375, 0.5, 0.725, 0.875, 1.0]
//            
//            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
//            let gStartPoint = CGPoint(x: 0, y: bounds.width/2)
//            let gEndPoint = CGPoint(x: bounds.width, y: bounds.width/2)
//            ctx.drawLinearGradient(gradient, start: gStartPoint, end: gEndPoint, options: [])
//            //TODO: Add axial shading gradient insteed of linear gradient
//            
//            ctx.restoreGState()
//            ctx.saveGState()
//            
//            let pEndDegree = min(max((colorBallView.bMinVal), colorBallView.bProgressValue), colorBallView.bMaxVal)
//            let pEndAngleRad = CGFloat(pEndDegree).degreesToRadians
//            
//            //progress Track
//            let startX = center.x + (radius * cos(startAngleRad))
//            let startY = center.y + (radius * sin(startAngleRad))
//            let startPoint: CGPoint = CGPoint(x: startX, y: startY)
//            
//            let ptrack = UIBezierPath()
//            ptrack.move(to: startPoint)
//            ptrack.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(pEndAngleRad), clockwise: false)
//            ptrack.addArc(withCenter: center, radius: radius - colorBallView.pTrackWidth , startAngle: CGFloat(pEndAngleRad), endAngle: startAngle, clockwise: true)
//            ptrack.addArc(withCenter: midPoint, radius: colorBallView.pTrackWidth/2, startAngle: 2 * startAngle, endAngle: startAngle, clockwise: false)
//            ctx.setLineCap(CGLineCap.round)
//            ctx.addPath(ptrack.cgPath)
//            ctx.clip()
//            ctx.fillPath()
//            
//            ctx.drawLinearGradient(gradient, start: gStartPoint, end: gEndPoint, options: [])
//            
//            ctx.restoreGState()
//            ctx.saveGState()
//            
//            //Thumb
//            let shadowHeight = 2 - (4 * ((pEndAngleRad - 0.5) / 2.1))
//            let newRadius = radius + colorBallView.trackWidth/2 - colorBallView.thumbWidth/2
//            
//            let newX = center.x + (newRadius * cos(pEndAngleRad))
//            let newY = center.y + (newRadius * sin(pEndAngleRad))
//            
//            let thumbRect = CGRect(x: newX - (colorBallView.thumbWidth/2 ), y: newY - (colorBallView.thumbWidth/2 ), width: colorBallView.thumbWidth, height: colorBallView.thumbWidth)
//            let color: UIColor!
//            if highlighted {
//                let c = CGPoint(x: newX, y: newY)
//                let pointInView = self.convert(c, to: colorBallView.layer)
//                let hueColor = colorBallView.getPixelColorAtPoint(point: pointInView)
//                color = UIColor(red: CGFloat(hueColor.red)/255.0, green: CGFloat(hueColor.green)/255.0, blue: CGFloat(hueColor.blue)/255.0, alpha: 1.0)
//                colorBallView.hueValues = (hueColor.red, hueColor.green, hueColor.blue)
//            } else {
//                let hueColor: UIColor  = UIColor(red: CGFloat(colorBallView.hueValues.0)/255.0, green: CGFloat(colorBallView.hueValues.1)/255.0, blue: CGFloat(colorBallView.hueValues.2)/255.0, alpha: 1.0)
//                color = hueColor
//            }
//            let thumbPath = UIBezierPath(ovalIn: thumbRect)
//            let shadowColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5)
//            ctx.setShadow(offset:  CGSize(width: -2, height: shadowHeight), blur: 0.4, color: shadowColor.cgColor)
//            ctx.addPath(thumbPath.cgPath)
//            let thumbColor: UIColor = color.withAlphaComponent(1.0)
//            ctx.setFillColor(thumbColor.cgColor)
//            ctx.fillPath()
//        }
//    }
//}
//
//extension FloatingPoint {
//    var degreesToRadians: Self { return self * .pi / 180 }
//    var radiansToDegrees: Self { return self * 180 / .pi }
//}
//

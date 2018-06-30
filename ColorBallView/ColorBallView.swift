//
//  ColorBallView.swift
//  ColorBallView
//
//  Created by Iraniya Naynesh on 15/06/18.
//  Copyright © 2018 Iraniya. All rights reserved.
//

enum LayerType {
    case none
    case colorBall
    case topTrack
    case bottomTrack
}

import UIKit
import QuartzCore
import Foundation

@objc public protocol ColorBallViewDelegate: NSObjectProtocol {
    @objc optional func colorBallView(_ colorBall: ColorBallView, topProgressValue value: Float) -> Float
    @objc optional func colorBallView(_ colorBall: ColorBallView, bottomProgressValue value: Float) -> Float
}


@IBDesignable
open class ColorBallView: UIControl, CAAnimationDelegate {
    
    //Settings
    open weak var delegate: ColorBallViewDelegate?
    var padding: CGFloat = 15.0
    
    var touchActive: Bool = true
    @IBInspectable var touchEnable: Bool = false { didSet { updateLayerFrames() } }
    
    var trackWidth: CGFloat = 5 {
        didSet {
            tTrackLayer.setNeedsDisplay()
            bTrackLayer.setNeedsDisplay()
        }
    }
    
    var pTrackWidth: CGFloat = 20 {
        didSet {
            tTrackLayer.setNeedsDisplay()
            bTrackLayer.setNeedsDisplay()
        }
    }
    
    var thumbWidth: CGFloat = 25 {
        didSet {
            tTrackLayer.setNeedsDisplay()
            bTrackLayer.setNeedsDisplay()
        }
    }
    
    //Colors
    @IBInspectable
    var bgColor: UIColor = #colorLiteral(red: 0.1689999998, green: 0.172999993, blue: 0.1659999937, alpha: 1) { didSet { updateLayerFrames() } }
    var BColorList = [#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor]
    var tColorList = [#colorLiteral(red: 0.9222484827, green: 0.9666373134, blue: 0.9786973596, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.996109426, blue: 0.9671698213, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.9868641496, blue: 0.8582196832, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.9804955125, blue: 0.7723715901, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.9696907401, blue: 0.6727537513, alpha: 1).cgColor]
   
    //Top slider
    /*
     TO adjust the brightness and defusion of the colorball
     */
    var tMinVal: Double = 210  {
        didSet {
            tTrackLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    var tMaxVal: Double = 330  {
        didSet {
            tTrackLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable var tProgressValue: Double = 300 {
        didSet {
            tTrackLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    var tTrackColorList: [UIColor] = [UIColor]()
    
    //bottom slider
    var bMinVal: Double = 30  {
        didSet {
            bTrackLayer.setNeedsDisplay()
            colorBallLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    var bMaxVal: Double = 150  {
        didSet {
            bTrackLayer.setNeedsDisplay()
            colorBallLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable var bProgressValue: Double = 120 {
        didSet {
            bTrackLayer.setNeedsDisplay()
            colorBallLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    //Ball
    var outsideColor: UIColor = UIColor.red {
        didSet {
            colorBallLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    var insideColor: UIColor = UIColor.white {
        didSet {
            colorBallLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    var trackingPonint: CGPoint = CGPoint(x: 150, y: 150) {
        didSet {
            colorBallLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    
    var selectedColor: UIColor = UIColor.red {
        didSet {
            dBallLayer.setNeedsDisplay()
        }
    }
    
    //Layers in order of drawing
    let dBallLayer = DefusionBallLayer()
    let tTrackLayer = TopSliderLayer()
    let bTrackLayer = BottomSliderLayer()
    let colorBallLayer = ColorballLayer()
    
    override open var frame: CGRect { didSet { updateLayerFrames() } }
    override open func layoutSubviews() { updateLayerFrames() }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setUpColorBallView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
        setUpColorBallView()
    }
    
    func setUpColorBallView() {
        
        //defusion Ball
        dBallLayer.colorBallView = self
        dBallLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(dBallLayer)
        
        //only add the progress layer if needed
        //Top progress track
        tTrackLayer.colorBallView = self
        tTrackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(tTrackLayer)
        
        //Bottom Progress track
        bTrackLayer.colorBallView = self
        bTrackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(bTrackLayer)
        
        //center color ball
        colorBallLayer.colorBallView = self
        colorBallLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(colorBallLayer)
        
        updateLayerFrames()
        
        stopTracking()
    }
    
    func updateLayerFrames() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        //frams for defusion ball
        let dPadding: CGFloat = self.bounds.width - padding
        let dBallS = CGRect(x: dPadding, y: dPadding, width: self.bounds.width - (2 * dPadding), height: self.bounds.width - (2 * dPadding))
        dBallLayer.frame = dBallS
        dBallLayer.setNeedsDisplay()
        
        if touchEnable {
            tTrackLayer.isHidden = false
            bTrackLayer.isHidden = false
            //frames for top progress tracking
            let tTrackFrame: CGRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height/2)
            tTrackLayer.frame = tTrackFrame
            tTrackLayer.setNeedsDisplay()
            
            //frames for bottom progress tracking
            let bTrackFrame: CGRect = CGRect(x: 0, y: bounds.height/2, width: bounds.width, height: bounds.height/2)
            bTrackLayer.frame = bTrackFrame
            bTrackLayer.setNeedsDisplay()
        } else {
            tTrackLayer.isHidden = true
            bTrackLayer.isHidden = true
        }
        
        //frams for center color ball
        let lPadding: CGFloat = self.bounds.width/3.6 - padding
        let lightColorS = CGRect(x: lPadding, y: lPadding, width: self.bounds.width - (2 * lPadding), height: self.bounds.width - (2 * lPadding))
        colorBallLayer.frame = lightColorS
        colorBallLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        colorBallLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    //MARK: Touch methods
    var previousLoaction = CGPoint()

    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        if !touchEnable {
            return false
        }
        
        resetLayers()
        startTracking()
        
        if !touchActive {
            touchActive = true
            return false
        }
        
        previousLoaction = touch.location(in: self)
        
        if colorBallLayer.frame.contains(previousLoaction) {
            colorBallLayer.highlighted = true
            //get the color on the touched point inside the ball
            trackingPonint = previousLoaction
            let color = getPixelColorAtPoint(point: trackingPonint)
            print(color)
            selectedColor = color
            return true
        }
        
        if tTrackLayer.frame.contains(previousLoaction) {
            tTrackLayer.highlighted = true
            getAngle(fromPoint: previousLoaction)
            
            return true
        }
        
        if bTrackLayer.frame.contains(previousLoaction) {
            bTrackLayer.highlighted = true
            getAngle(fromPoint: previousLoaction)
            return true
        }
        
        return false
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        previousLoaction = touch.location(in: self)
        
        if colorBallLayer.highlighted  {
            if colorBallLayer.frame.contains(previousLoaction) {
                //get the color from the ball
                trackingPonint = previousLoaction
                updateLayers()
                return true
            }
            resetLayers()
            return false
        }
        
        if tTrackLayer.highlighted {
            getAngle(fromPoint: previousLoaction)
            return true
        }
        
        if bTrackLayer.highlighted {
            getAngle(fromPoint: previousLoaction)
            return true
        }
        resetLayers()
        return false
        
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        resetLayers()
        stopTracking()
    }
    
    open override func cancelTracking(with event: UIEvent?) {
        resetLayers()
        stopTracking()
    }
    
    func resetLayers() {
        colorBallLayer.highlighted = false
        tTrackLayer.highlighted = false
        bTrackLayer.highlighted = false
    }
    
    func getAngle(fromPoint point: CGPoint) {
        let cCenter = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let angle: CGFloat = CGFloat(atan2(point.y - cCenter.y , -(point.x - cCenter.x))).radiansToDegrees
        if tTrackLayer.highlighted {
            //need to update top slider
            if (angle < -180 || angle > 0)   { return }
            let topNewAngle: Double = Double(abs(angle) + 180)
            tProgressValue = boundValues(value: topNewAngle, toLowerValue: tMinVal, upperValue: tMaxVal)
            //tProgressValue
        } else if bTrackLayer.highlighted {
            //need to update bottom slider
            if angle < 0 || angle > 180 { return }
            let bottomNewAngle = 180 - angle
            bProgressValue = Double(bottomNewAngle)
        }
    }
    
    func boundValues(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    //MARK: FadeInOut animation
    func startTracking() {
        print("Start Tracking")
        self.tTrackLayer.opacity = 1.0
        self.bTrackLayer.opacity = 1.0
        colorBallLayer.showTracking = true
        tTrackLayer.removeAllAnimations()
        bTrackLayer.removeAllAnimations()
    }
    
    func stopTracking() {
        print("Stop tracking")
        colorBallLayer.showTracking = false
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.delegate = self
        fadeOutAnimation.beginTime = CACurrentMediaTime() + 10.0
        fadeOutAnimation.duration = 3.0
        fadeOutAnimation.fromValue = 1.0
        fadeOutAnimation.toValue = 0.0
        fadeOutAnimation.isRemovedOnCompletion = false
        fadeOutAnimation.fillMode = kCAFillModeBoth
        fadeOutAnimation.isAdditive = false
        tTrackLayer.add(fadeOutAnimation, forKey: "opacityOUT")
        bTrackLayer.add(fadeOutAnimation, forKey: "opacityOUT")
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            touchActive = false
        }
    }
    
    func getPixelColorAtPoint(point:CGPoint) -> UIColor {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context?.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0, green: CGFloat(pixel[1])/255.0, blue: CGFloat(pixel[2])/255.0, alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deinitialize(count: 4)
        return color
    }
    
    func updateLayers() {
        let color = getPixelColorAtPoint(point: trackingPonint)
        selectedColor = color
    }
}


class ColorballLayer: CALayer {
    
    weak var colorBallView: ColorBallView?
    var  highlighted: Bool = false
    var width: CGFloat  { return bounds.width }
    var height: CGFloat { return bounds.height }
    var showTracking: Bool = false { didSet { setNeedsDisplay() } }
    
    override func draw(in ctx: CGContext) {
        if let colorBallView = colorBallView {
            //get the circle
            ctx.saveGState()
            let center = CGPoint(x: width/2, y: height/2)
            let radius: CGFloat = ((width>height) ? height : width)/2
            ctx.beginPath()
            //arc is from 0 to 2pi making it full circle
            ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
            ctx.clip()
            
            //Fill the circle with white and oustside color
            let colors = [colorBallView.insideColor.cgColor, colorBallView.outsideColor.cgColor] as CFArray
            let colorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            let endRadius: CGFloat = sqrt(pow(frame.width/2, 2) + pow(frame.height/2, 2))
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.9])
            ctx.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: endRadius, options: CGGradientDrawingOptions.init(rawValue: 1))
            
//            if showTracking {
//                let trackingCenter: CGPoint = CGPoint(x: colorBallView.trackingPonint.x - anchorPoint.x , y: colorBallView.trackingPonint.y - anchorPoint.y)
//                let tc = colorBallView.layer.convert(trackingCenter, to: self)
//                let dist = distance(tc, center)
//                if dist <= radius {
//                    let finalTcX:CGFloat = min(max(0, tc.x), width)
//                    let finalTcY:CGFloat = min(max(0, tc.y), height)
//                    self.masksToBounds = false
//                    let trackingCircle =  UIBezierPath()
//                    trackingCircle.addArc(withCenter: CGPoint(x: finalTcX, y: finalTcY), radius: 8, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
//                    trackingCircle.close()
//                    ctx.addPath(trackingCircle.cgPath)
//                    ctx.setFillColor(UIColor.white.cgColor)
//                    ctx.fillPath()
//                }
//            }
            
        }
    }
    
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}

class DefusionBallLayer: CALayer {
    
    weak var colorBallView: ColorBallView?
    var width: CGFloat { return bounds.width }
    var height: CGFloat { return bounds.height }
    
    override func draw(in ctx: CGContext) {
        if let colorBallView = colorBallView {
            
            //get the circle
            let center = CGPoint(x: width/2, y: height/2)
            let radius: CGFloat = ((width>height) ? height : width)/2
            ctx.beginPath()
            
            //draw circle
            ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
            ctx.closePath()
            ctx.clip()
            let alpaVale: CGFloat = CGFloat((colorBallView.tProgressValue - 210 ) / 120)
            
            // Radial gradient
            let colorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            let colors = [colorBallView.selectedColor.withAlphaComponent(alpaVale).cgColor, colorBallView.bgColor.withAlphaComponent(alpaVale).cgColor] as CFArray
            
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1.0])
            ctx.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        }
    }
}

class TopSliderLayer: CALayer {
    
    weak var colorBallView: ColorBallView?
    var highlighted: Bool = false
    var width: CGFloat { return bounds.width }
    var height: CGFloat { return bounds.height }
    var center: CGPoint {
        return CGPoint(x: bounds.width / 2, y: bounds.height)
    }
    var radius: CGFloat {
        return (bounds.width/2) - colorBallView!.padding
    }
    
    override func draw(in ctx: CGContext) {
        
        if let colorBallView = colorBallView {
            
            let startAngle: CGFloat = CGFloat(colorBallView.tMinVal).degreesToRadians
            let endAngle: CGFloat =  CGFloat((colorBallView.tMaxVal)).degreesToRadians
            
            let centerRad  = radius - colorBallView.pTrackWidth/2
            let startAngleRad = CGFloat(colorBallView.tMinVal).degreesToRadians
            let mindPointX = center.x + (centerRad * cos(startAngleRad))
            let midPointY = center.y + (centerRad * sin(startAngleRad))
            let midPoint: CGPoint = CGPoint(x: mindPointX, y: midPointY)
            
            let tCRad  = radius - colorBallView.pTrackWidth/2 + colorBallView.trackWidth/2
            let endAngleRad = CGFloat(colorBallView.tMaxVal).degreesToRadians
            let endMidPointX = center.x + (tCRad * cos(endAngleRad))
            let endMidPointY = center.y + (tCRad * sin(endAngleRad))
            let endMidPoint: CGPoint = CGPoint(x: endMidPointX, y: endMidPointY)
            
            ctx.beginPath()
            ctx.saveGState()
            
            //Track
            let track = UIBezierPath()
            track.addArc(withCenter: center, radius: radius - colorBallView.pTrackWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            track.addArc(withCenter: endMidPoint, radius: colorBallView.trackWidth/2, startAngle: CGFloat(2 * Double.pi), endAngle: 0, clockwise: false)
            track.addArc(withCenter: center, radius: radius - colorBallView.trackWidth , startAngle: endAngle, endAngle: startAngle, clockwise: false)
            track.close()
            ctx.setLineJoin(CGLineJoin.round)
            ctx.setLineCap(CGLineCap.round)
            ctx.addPath(track.cgPath)
            ctx.clip()
            ctx.fillPath()
            
            //Gradient fill
            let colors = colorBallView.tColorList
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations: [CGFloat] = [0.0, 0.25, 0.5, 0.75, 1.0]
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
            let gStartPoint = CGPoint(x: 0, y: 0.5)
            let gEndPoint = CGPoint(x: bounds.width, y: 0.5)
            ctx.drawLinearGradient(gradient, start: gStartPoint, end: gEndPoint, options: [])
            
            ctx.restoreGState()
            ctx.saveGState()
            
            let pEndDegree = min(max((colorBallView.tMinVal), colorBallView.tProgressValue), colorBallView.tMaxVal)
            let pEndAngleRad = CGFloat(pEndDegree).degreesToRadians
            
            //progress Track
            let startX = center.x + (radius * cos(startAngleRad))
            let startY = center.y + (radius * sin(startAngleRad))
            let startPoint: CGPoint = CGPoint(x: startX, y: startY)
            
            let ptrack = UIBezierPath()
            ptrack.move(to: startPoint)
            ptrack.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(pEndAngleRad), clockwise: true)
            ptrack.addArc(withCenter: center, radius: radius - colorBallView.pTrackWidth , startAngle: CGFloat(pEndAngleRad), endAngle: startAngle, clockwise: false)
            
            ptrack.addArc(withCenter: midPoint, radius: colorBallView.pTrackWidth/2, startAngle: 2 * startAngle, endAngle: startAngle, clockwise: true)
            ctx.setLineCap(CGLineCap.round)
            ctx.addPath(ptrack.cgPath)
            ctx.clip()
            ctx.fillPath()
            
            ctx.drawLinearGradient(gradient, start: gStartPoint, end: gEndPoint, options: [])
            
            ctx.restoreGState()
            ctx.saveGState()
            
            //shadow
            let shadowHeight = 2 - (4 * ((pEndAngleRad - 3.6) / 2.1))
            let newRadius = radius + colorBallView.trackWidth/2 - colorBallView.thumbWidth/2
            
            //Thumb
            let newX = center.x + (newRadius * cos(pEndAngleRad))
            let newY = center.y + (newRadius * sin(pEndAngleRad))
            
            let thumbRect = CGRect(x: newX - (colorBallView.thumbWidth/2 ), y: newY - (colorBallView.thumbWidth/2 ), width: colorBallView.thumbWidth, height: colorBallView.thumbWidth)
            
            let thumbPath = UIBezierPath(ovalIn: thumbRect)
            let shadowColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5)
            ctx.setShadow(offset:  CGSize(width: -2, height: shadowHeight), blur: 0.4, color: shadowColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            let thumbColor: UIColor = UIColor.white
            ctx.setFillColor(thumbColor.cgColor)
            ctx.fillPath()
        }
    }
    
    func updateTrack() {
        
    }
}

class BottomSliderLayer: CALayer {
    
    weak var colorBallView: ColorBallView?
    var highlighted: Bool = false
    var width: CGFloat { return bounds.width }
    var height: CGFloat { return bounds.height }
    
    override func draw(in ctx: CGContext) {
        if let colorBallView = colorBallView {
            
            let center = CGPoint(x: bounds.width / 2, y: 0)
            let radius: CGFloat =  (bounds.width/2) - colorBallView.padding
            let startAngle: CGFloat = CGFloat(colorBallView.bMaxVal).degreesToRadians
            let endAngle: CGFloat = CGFloat(colorBallView.bMinVal).degreesToRadians
            
            let centerRad  = radius - colorBallView.pTrackWidth/2
            let startAngleRad = CGFloat(colorBallView.bMaxVal).degreesToRadians
            let mindPointX = center.x + (centerRad * cos(startAngleRad))
            let midPointY = center.y + (centerRad * sin(startAngleRad))
            let midPoint: CGPoint = CGPoint(x: mindPointX, y: midPointY)
            
            let tCRad  = radius - colorBallView.pTrackWidth/2 + colorBallView.trackWidth/2
            let endAngleRad = CGFloat(colorBallView.bMinVal).degreesToRadians
            let endMidPointX = center.x + (tCRad * cos(endAngleRad))
            let endMidPointY = center.y + (tCRad * sin(endAngleRad))
            let endMidPoint: CGPoint = CGPoint(x: endMidPointX, y: endMidPointY)
            
            ctx.beginPath()
            ctx.saveGState()
            
            //Track
            let track = UIBezierPath()
            track.addArc(withCenter: center, radius: radius - colorBallView.pTrackWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            track.addArc(withCenter: endMidPoint, radius: colorBallView.trackWidth/2, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            track.addArc(withCenter: center, radius: radius - colorBallView.trackWidth , startAngle: endAngle, endAngle: startAngle, clockwise: true)
            track.close()
            ctx.setLineJoin(CGLineJoin.round)
            ctx.setLineCap(CGLineCap.round)
            ctx.addPath(track.cgPath)
            ctx.clip()
            ctx.fillPath()
            
            //Gradient fill
            let colors = colorBallView.BColorList
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colorLocations: [CGFloat] = [0.0, 0.125, 0.375, 0.5, 0.725, 0.875, 1.0]
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
            let gStartPoint = CGPoint(x: colorBallView.padding, y: colorBallView.padding)
            let gEndPoint = CGPoint(x: bounds.width - colorBallView.padding, y: bounds.height - colorBallView.padding)
            ctx.drawLinearGradient(gradient, start: gStartPoint, end: gEndPoint, options: [])
            
            ctx.restoreGState()
            ctx.saveGState()
            
            let pEndDegree = min(max((colorBallView.bMinVal), colorBallView.bProgressValue), colorBallView.bMaxVal)
            let pEndAngleRad = CGFloat(pEndDegree).degreesToRadians
            
            //progress Track
            let startX = center.x + (radius * cos(startAngleRad))
            let startY = center.y + (radius * sin(startAngleRad))
            let startPoint: CGPoint = CGPoint(x: startX, y: startY)
            
            let ptrack = UIBezierPath()
            ptrack.move(to: startPoint)
            ptrack.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(pEndAngleRad), clockwise: false)
            ptrack.addArc(withCenter: center, radius: radius - colorBallView.pTrackWidth , startAngle: CGFloat(pEndAngleRad), endAngle: startAngle, clockwise: true)
            
            ptrack.addArc(withCenter: midPoint, radius: colorBallView.pTrackWidth/2, startAngle: 2 * startAngle, endAngle: startAngle, clockwise: false)
            ctx.setLineCap(CGLineCap.round)
            ctx.addPath(ptrack.cgPath)
            ctx.clip()
            ctx.fillPath()
            
            ctx.drawLinearGradient(gradient, start: gStartPoint, end: gEndPoint, options: [])
            
            ctx.restoreGState()
            ctx.saveGState()
            
            //Thumb
            let shadowHeight = 2 - (4 * ((pEndAngleRad - 0.5) / 2.1))
            let newRadius = radius + colorBallView.trackWidth/2 - colorBallView.thumbWidth/2
            
            let newX = center.x + (newRadius * cos(pEndAngleRad))
            let newY = center.y + (newRadius * sin(pEndAngleRad))
           
            let thumbRect = CGRect(x: newX - (colorBallView.thumbWidth/2 ), y: newY - (colorBallView.thumbWidth/2 ), width: colorBallView.thumbWidth, height: colorBallView.thumbWidth)
            let c = CGPoint(x: newX, y: newY)
            print(c)
            let pointInView = self.convert(c, to: colorBallView.layer)
            let selectedColor = colorBallView.getPixelColorAtPoint(point: pointInView)
            print(selectedColor)
            colorBallView.outsideColor = selectedColor
            colorBallView.updateLayers()
            let thumbPath = UIBezierPath(ovalIn: thumbRect)
            let shadowColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5)
            ctx.setShadow(offset:  CGSize(width: -2, height: shadowHeight), blur: 0.4, color: shadowColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            let thumbColor: UIColor = UIColor.white
            ctx.setFillColor(thumbColor.cgColor)
            ctx.fillPath()
        }
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}


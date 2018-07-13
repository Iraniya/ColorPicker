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

public protocol ColorBallViewDelegate: NSObjectProtocol {
    func colorBallView(_ colorBall: ColorBallView, withSelectedColorValues selectedRGB: (Int, Int, Int), andHueColor hueColor:(Int, Int, Int), withBrightness brightness: Int, userInteractionFinished: Bool, hueAngle: Double, brightnessAngle: Double)
}

@IBDesignable
open class ColorBallView: UIControl, CAAnimationDelegate {
    
    //Settings
    open weak var delegate: ColorBallViewDelegate?
    var padding: CGFloat = 15.0 { didSet { updateLayerFrames() } }
    
    var touchActive: Bool = true
    @IBInspectable var touchEnable: Bool = false { didSet { updateLayerFrames() } }
    
    var trackWidth: CGFloat = 5
    var pTrackWidth: CGFloat = 20
    var thumbWidth: CGFloat = 25
    
    var isShadesOfWhite: Bool = false { didSet { updateLayerFrames() } }
    
    //Colors
    @IBInspectable
    var bgColor: UIColor = #colorLiteral(red: 0.1689999998, green: 0.172999993, blue: 0.1659999937, alpha: 1) { didSet { updateLayerFrames() } }
    var tColorList = [#colorLiteral(red: 0.9222484827, green: 0.9666373134, blue: 0.9786973596, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.996109426, blue: 0.9671698213, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.9868641496, blue: 0.8582196832, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.9804955125, blue: 0.7723715901, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0.9696907401, blue: 0.6727537513, alpha: 1).cgColor]
    var BColorList = [#colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1).cgColor, #colorLiteral(red: 0, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1).cgColor]
    var BSColorList = [#colorLiteral(red: 0.9960784314, green: 0.9607843137, blue: 0.6392156863, alpha: 1).cgColor, #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor, #colorLiteral(red: 0.5490196078, green: 0.768627451, blue: 0.9176470588, alpha: 1).cgColor]
    var tMinVal: Double = 210
    var tMaxVal: Double = 330
    
    @IBInspectable var tProgressValue: Double = 330 {
        didSet {
            tTrackView.setNeedsDisplay()
            dBallView.setNeedsDisplay()
        }
    }
    
    var tTrackColorList: [UIColor] = [UIColor]()
    
    //bottom slider
    var bMinVal: Double = 30
    var bMaxVal: Double = 150
    
    @IBInspectable var bProgressValue: Double = 150 {
        didSet {
            bTrackView.setNeedsDisplay()
            colorBallView.setNeedsDisplay()
            dBallView.setNeedsDisplay()
        }
    }
    
    var tSelectedColor: UIColor = UIColor.white
    var insideColor: UIColor = UIColor.white
    
    var trackingPonint: CGPoint! {
        didSet {
            colorBallView.setNeedsDisplay()
            dBallView.setNeedsDisplay()
            updateTrackingPoint()
        }
    }
    
    var selectedRGB: (Int, Int, Int) = (255, 255, 255) {
        didSet {
            dBallView.setNeedsDisplay()
        }
    }
    
    var hueValues: (Int, Int, Int) = (255, 0, 0) {
        didSet {
            colorBallView.setNeedsDisplay()
            dBallView.setNeedsDisplay()
        }
    }
    
    var selectedBrighness: Int = 200 {
        didSet {
            dBallView.setNeedsDisplay()
        }
    }
    
    //Layers in order of drawing
    let dBallView = DefusionBallView()
    let tTrackView = TopSliderView()
    let bTrackView = BottomSliderView()
    let colorBallView = ColorballView()
    
    var trackingView: UIView = {
        let view  = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        view.layer.borderWidth = 3.0
        view.layer.cornerRadius = 10.0
        view.clipsToBounds = true
        return view
    }()
    
    override open var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    override open func layoutSubviews() {
        updateLayerFrames()
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        trackingPonint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        setUpColorBallView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        trackingPonint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        setUpColorBallView()
    }
    
    func setUpColorBallView() {
        
        //defusion Ball
        dBallView.colorBallView = self
        dBallView.layer.contentsScale = UIScreen.main.scale
        dBallView.isUserInteractionEnabled = false
        dBallView.backgroundColor = UIColor.clear
        dBallView.alpha = 0.7
        self.addSubview(dBallView)
        
        //Top progress track
        tTrackView.colorBallView = self
        tTrackView.layer.contentsScale = UIScreen.main.scale
        tTrackView.isUserInteractionEnabled = false
        tTrackView.backgroundColor = UIColor.clear
        self.addSubview(tTrackView)
        
        //Bottom Progress track
        bTrackView.colorBallView = self
        bTrackView.layer.contentsScale = UIScreen.main.scale
        bTrackView.isUserInteractionEnabled = false
        bTrackView.backgroundColor = UIColor.clear
        self.addSubview(bTrackView)
        
        //center color ball
        colorBallView.colorBallView = self
        colorBallView.layer.contentsScale = UIScreen.main.scale
        colorBallView.isUserInteractionEnabled = false
        colorBallView.backgroundColor = UIColor.clear
        self.addSubview(colorBallView)
        
        self.addSubview(trackingView)
        self.bringSubview(toFront: trackingView)
        updateLayerFrames()
        stopTracking()
    }
    
    func updateLayerFrames() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        
        //frams for defusion ball
        let dPadding: CGFloat = self.bounds.width - padding
        let dBallS = CGRect(x: dPadding, y: dPadding, width: self.bounds.width - (2 * dPadding), height: self.bounds.width - (2 * dPadding))
        dBallView.frame = dBallS
        dBallView.setNeedsDisplay()
        
        if touchEnable {
            tTrackView.isHidden = false
            bTrackView.isHidden = false
            //frames for top progress tracking
            let tTrackFrame: CGRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height/2)
            tTrackView.frame = tTrackFrame
            tTrackView.setNeedsDisplay()
            
            //frames for bottom progress tracking
            let bTrackFrame: CGRect = CGRect(x: 0, y: bounds.height/2, width: bounds.width, height: bounds.height/2)
            bTrackView.frame = bTrackFrame
            bTrackView.setNeedsDisplay()
        } else {
            tTrackView.isHidden = true
            bTrackView.isHidden = true
        }
        
        //frams for center color ball
        let lPadding: CGFloat = self.bounds.width/3.6 - padding
        let lightColorS = CGRect(x: lPadding, y: lPadding, width: self.bounds.width - (2 * lPadding), height: self.bounds.width - (2 * lPadding))
        colorBallView.frame = lightColorS
        colorBallView.layer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        colorBallView.setNeedsDisplay()
        
        if touchEnable {
            trackingView.isHidden = false
            trackingView.frame = CGRect(x: 0, y: 0, width: 20.0, height: 20.0)
            trackingView.center = trackingPonint
            self.bringSubview(toFront: trackingView)
        } else {
            trackingView.isHidden = true
        }
        
        CATransaction.commit()
    }
    
    func updateTrackingPoint() {
        trackingView.center = trackingPonint
        trackingView.layoutIfNeeded()
    }
    
    //MARK: Touch methods
    var previousLoaction = CGPoint()
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        if !touchEnable { return false }
        
        resetLayers()
        startTracking()
        
        if !touchActive {
            touchActive = true
            return false
        }
        
        previousLoaction = touch.location(in: self)
        
        if colorBallView.layer.frame.contains(previousLoaction) {
            colorBallView.highlighted = true
            let newPoint = isTrackingPointInsideTheColorBallView(trackingPoint: previousLoaction)
            trackingPonint = newPoint
            updateTrackingView()
            return true
        }
        
        if tTrackView.frame.contains(previousLoaction) {
            tTrackView.highlighted = true
            getAngle(fromPoint: previousLoaction)
            let tAngle = getBrightnessValue(fromAngle: tProgressValue - tMinVal)
            delegate?.colorBallView(self, withSelectedColorValues: self.selectedRGB, andHueColor: self.hueValues, withBrightness: tAngle, userInteractionFinished: false, hueAngle: bProgressValue, brightnessAngle: tProgressValue)
            return true
        }
        
        if bTrackView.frame.contains(previousLoaction) {
            bTrackView.highlighted = true
            getAngle(fromPoint: previousLoaction)
            let bAngle = getBrightnessValue(fromAngle: tProgressValue - tMinVal)
            delegate?.colorBallView(self, withSelectedColorValues: self.selectedRGB, andHueColor: self.hueValues, withBrightness: bAngle, userInteractionFinished: false, hueAngle: bProgressValue, brightnessAngle: tProgressValue)
            return true
        }
        
        return false
    }
    
    open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        previousLoaction = touch.location(in: self)
        
        if colorBallView.highlighted  {
            //get the color from the ball
            let newPoint = isTrackingPointInsideTheColorBallView(trackingPoint: previousLoaction)
            trackingPonint = newPoint
            trackingView.center = trackingPonint
            updateTrackingView()
            return true
        }
        
        if tTrackView.highlighted {
            getAngle(fromPoint: previousLoaction)
            let tAngle = getBrightnessValue(fromAngle: tProgressValue - tMinVal)
            delegate?.colorBallView(self, withSelectedColorValues: self.selectedRGB, andHueColor: self.hueValues, withBrightness: tAngle, userInteractionFinished: false, hueAngle: bProgressValue, brightnessAngle: tProgressValue)
            return true
        }
        
        if bTrackView.highlighted {
            getAngle(fromPoint: previousLoaction)
            let bAngle = getBrightnessValue(fromAngle: tProgressValue - tMinVal)
            delegate?.colorBallView(self, withSelectedColorValues: self.selectedRGB, andHueColor: self.hueValues, withBrightness: bAngle, userInteractionFinished: false, hueAngle: bProgressValue, brightnessAngle: tProgressValue)
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
        colorBallView.highlighted = false
        tTrackView.highlighted = false
        bTrackView.highlighted = false
    }
    
    func getAngle(fromPoint point: CGPoint) {
        let cCenter = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let angle: CGFloat = CGFloat(atan2(point.y - cCenter.y , -(point.x - cCenter.x))).radiansToDegrees
        if tTrackView.highlighted {
            //need to update top slider
            if (angle < -180 || angle > 0)   { return }
            let topNewAngle: Double = Double(abs(angle) + 180)
            tProgressValue = boundValues(value: topNewAngle, toLowerValue: tMinVal, upperValue: tMaxVal)
            //tProgressValue
        } else if bTrackView.highlighted {
            //need to update bottom slider
            if angle < 0 || angle > 180 { return }
            let bottomNewAngle: Double = Double(180 - angle)
            bProgressValue = boundValues(value: bottomNewAngle, toLowerValue: bMinVal, upperValue: bMaxVal)
        }
    }
    
    func boundValues(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    //MARK: FadeInOut animation
    func startTracking() {
        print("Start Tracking")
        self.tTrackView.layer.opacity = 1.0
        self.bTrackView.layer.opacity = 1.0
        self.trackingView.layer.opacity = 1.0
        colorBallView.showTracking = true
        tTrackView.layer.removeAllAnimations()
        bTrackView.layer.removeAllAnimations()
        trackingView.layer.removeAllAnimations()
    }
    
    func stopTracking() {
        print("Stop tracking")
        colorBallView.showTracking = false
        let fadeOutAnimation = CABasicAnimation(keyPath: "opacity")
        fadeOutAnimation.setValue("opacityOUT", forKey: "AnimationType")
        fadeOutAnimation.delegate = self
        fadeOutAnimation.beginTime = CACurrentMediaTime() + 10.0
        fadeOutAnimation.duration = 3.0
        fadeOutAnimation.fromValue = 1.0
        fadeOutAnimation.toValue = 0.0
        fadeOutAnimation.isRemovedOnCompletion = false
        fadeOutAnimation.fillMode = kCAFillModeBoth
        fadeOutAnimation.isAdditive = false
        tTrackView.layer.add(fadeOutAnimation, forKey: "opacityOUT")
        bTrackView.layer.add(fadeOutAnimation, forKey: "opacityOUT")
        trackingView.layer.add(fadeOutAnimation, forKey: "opacityOUT")
        let bAngle = getBrightnessValue(fromAngle: tProgressValue - tMinVal)
        delegate?.colorBallView(self, withSelectedColorValues: self.selectedRGB, andHueColor: self.hueValues, withBrightness: bAngle, userInteractionFinished: true, hueAngle: bProgressValue, brightnessAngle: tProgressValue)
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        let animationValue = anim.value(forKey: "AnimationType") as? String
        if animationValue == "opacityOUT" {
            if flag {
                touchActive = false
            }
        }
    }
    
    func getPixelColorAtPoint(point:CGPoint) -> (red: Int, green: Int, blue:Int) {
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue)
        context?.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        pixel.deinitialize(count: 4)
        return (Int(pixel[0]), Int(pixel[1]), Int(pixel[2]))
    }
    
    func updateTrackingView() {
        if trackingPonint == nil { trackingPonint = CGPoint(x: bounds.width/2, y: bounds.height/2) }
        trackingView.backgroundColor = UIColor.clear
        let colorValues = getPixelColorAtPoint(point: trackingPonint)
        self.selectedRGB = colorValues
        let c: UIColor = UIColor(red: CGFloat(colorValues.red)/255, green: CGFloat(colorValues.green)/255, blue: CGFloat(colorValues.blue)/255, alpha: 1.0)
        trackingView.backgroundColor = c
        let bAngle = getBrightnessValue(fromAngle: tProgressValue - tMinVal)
        delegate?.colorBallView(self, withSelectedColorValues: self.selectedRGB, andHueColor: self.hueValues, withBrightness: bAngle, userInteractionFinished: false, hueAngle: bProgressValue, brightnessAngle: tProgressValue)
        dBallView.setNeedsDisplay()
    }
    
    func isTrackingPointInsideTheColorBallView(trackingPoint: CGPoint) -> CGPoint {
        
        let radius: CGFloat = colorBallView.bounds.width/2
        let colorBallCenter: CGPoint = colorBallView.layer.position
        let dist = distanceBetween(trackingPoint, colorBallCenter)
        if dist <= radius {
            return trackingPoint
        } else {
            let c = CGPoint(x: bounds.width/2, y: bounds.height/2)
            let angle =  atan2(trackingPoint.y - c.y, -(trackingPoint.x - c.x))
            let newX = c.x + ((radius - 2.0) * -cos(angle))
            let newY = c.y + ((radius - 2.0) *  sin(angle))
            
            return CGPoint(x: newX, y: newY)
        }
    }
    
    func distanceBetween(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func getBrightnessValue(fromAngle angle: Double) -> Int {
        let x = (angle * 200) / 120
        return Int(x)
    }
    
    func getAngle(FromBrightness brightness: Int) -> Double {
        let x = (brightness * 120)/200
        return Double(x)
    }
}


class ColorballView: UIView {
    
    weak var colorBallView: ColorBallView?
    var  highlighted: Bool = false
    var width: CGFloat  { return bounds.width }
    var height: CGFloat { return bounds.height }
    var showTracking: Bool = false { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        if let colorBallView = colorBallView {
            //get the circle
            ctx.saveGState()
            let center = CGPoint(x: width/2, y: height/2)
            let radius: CGFloat = ((width>height) ? height : width)/2
            ctx.beginPath()
            
            //arc is from 0 to 2pi to make it full circle
            let path = UIBezierPath()
            path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
            path.close()
            ctx.addPath(path.cgPath)
            ctx.clip()
            
            let endColor: UIColor = UIColor(red: CGFloat(colorBallView.hueValues.0)/255, green: CGFloat(colorBallView.hueValues.1)/255, blue: CGFloat(colorBallView.hueValues.2)/255, alpha: 1.0)
            
            //Fill the circle with white and oustside color
            let colors = [colorBallView.insideColor.cgColor, endColor.cgColor] as CFArray
            let colorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            let endRadius: CGFloat = sqrt(pow(frame.width/2, 2) + pow(frame.height/2, 2))
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0.0, 0.8])
            ctx.drawRadialGradient(gradient!, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: endRadius, options: [])
        }
    }
}

class DefusionBallView: UIView {
    
    weak var colorBallView: ColorBallView?
    var width: CGFloat { return bounds.width }
    var height: CGFloat { return bounds.height }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()!
        if let colorBallView = colorBallView {
            //get the circle
            let center = CGPoint(x: width/2, y: height/2)
            let radius: CGFloat = ((width>height) ? height : width)/2
            ctx.beginPath()
            
            //draw circle
            ctx.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
            ctx.closePath()
            ctx.clip()
            let a: CGFloat =  CGFloat((colorBallView.tProgressValue - 210 ) / 120)
            let alpaVale: CGFloat = max(0, min(a, 1.0))
            
            // Radial gradient
            let colorValues = colorBallView.selectedRGB
            let startColor: UIColor = UIColor(red: CGFloat(colorValues.0)/255.0, green: CGFloat(colorValues.1)/255.0, blue: CGFloat(colorValues.2)/255.0, alpha: 8.0)
            let transparentColor: UIColor = colorBallView.bgColor.withAlphaComponent(0.0)
            let colorSpace: CGColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            let colors = [startColor.withAlphaComponent(8.0).cgColor, transparentColor.cgColor ] as CFArray
            let startRadius: CGFloat = (colorBallView.colorBallView.frame.width/2) - 0.5
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, alpaVale])
            ctx.drawRadialGradient(gradient!, startCenter: center, startRadius: startRadius, endCenter: center, endRadius: radius, options: [])
        }
    }
}

class TopSliderView: UIView {
    
    weak var colorBallView: ColorBallView?
    var highlighted: Bool = false
    var width: CGFloat { return bounds.width }
    var height: CGFloat { return bounds.height }
    
    override func draw(_ rect: CGRect) {
        
        if let colorBallView = colorBallView {
            
            let ctx = UIGraphicsGetCurrentContext()!
            let center: CGPoint = CGPoint(x: bounds.width / 2, y: bounds.height)
            let radius: CGFloat =  (bounds.width/2) - colorBallView.padding
            let startAngle: CGFloat = CGFloat(colorBallView.tMinVal).degreesToRadians
            let endAngle: CGFloat = CGFloat(colorBallView.tMaxVal).degreesToRadians
            
            ctx.beginPath()
            ctx.saveGState()
            
            //Track Path
            let track = UIBezierPath()
            track.addArc(withCenter: center, radius: radius - colorBallView.pTrackWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            ctx.addPath(track.cgPath)
            ctx.setLineCap(CGLineCap.round)
            ctx.setLineWidth(colorBallView.trackWidth)
            ctx.strokePath()
            
            ctx.restoreGState()
            ctx.saveGState()
            
            //progress Track
            let pEndDegree = min(max((colorBallView.tMinVal), colorBallView.tProgressValue), colorBallView.tMaxVal)
            let pEndAngleRad = CGFloat(pEndDegree).degreesToRadians
            let ptrack = UIBezierPath()
            ptrack.addArc(withCenter: center, radius: radius - (colorBallView.pTrackWidth/2), startAngle: startAngle, endAngle: CGFloat(pEndAngleRad), clockwise: true)
            ctx.setLineCap(CGLineCap.round)
            ctx.addPath(ptrack.cgPath)
            ctx.setLineWidth(colorBallView.pTrackWidth)
            ctx.strokePath()
            
            //Gradient fill
            let colors = colorBallView.tColorList
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            let colorLocations: [CGFloat] = [0.0, 0.25, 0.5, 0.75, 1.0]
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
            let gStartPoint = CGPoint(x: 0, y: 0.5)
            let gEndPoint = CGPoint(x: bounds.width, y: 0.5)
            
            //setting blend mode to sourceIn so it will draw only on the paths
            ctx.setBlendMode(CGBlendMode.sourceIn)
            
            //TODO: Add axial shading gradient insteed of linear gradient
            ctx.drawLinearGradient(gradient, start: gStartPoint, end: gEndPoint, options: [])
            
            ctx.restoreGState()
            ctx.saveGState()
            
            //Thumb circle
            let shadowHeight = 2 - (4 * ((pEndAngleRad - 3.6) / 2.1))
            let newRadius = radius + colorBallView.trackWidth/2 - colorBallView.thumbWidth/2
            
            let newX = center.x + (newRadius * cos(pEndAngleRad))
            let newY = center.y + (newRadius * sin(pEndAngleRad))
            
            let thumbRect = CGRect(x: newX - (colorBallView.thumbWidth/2 ), y: newY - (colorBallView.thumbWidth/2 ), width: colorBallView.thumbWidth, height: colorBallView.thumbWidth)
            
            let color: UIColor!
            if highlighted {
                let c = CGPoint(x: newX, y: newY)
                let pointInView = self.layer.convert(c, to: colorBallView.layer)
                let colorValues = colorBallView.getPixelColorAtPoint(point: pointInView)
                color = UIColor(red: CGFloat(colorValues.red)/255.0, green: CGFloat(colorValues.green)/255.0, blue: CGFloat(colorValues.blue)/255.0, alpha: 1.0)
            } else {
                color = colorBallView.tSelectedColor
            }
            
            let thumbPath = UIBezierPath(ovalIn: thumbRect)
            let shadowColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5)
            ctx.setShadow(offset:  CGSize(width: -2, height: shadowHeight), blur: 0.4, color: shadowColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            let thumbColor: UIColor = color.withAlphaComponent(1.0)
            ctx.setFillColor(thumbColor.cgColor)
            ctx.fillPath()
        }
    }
}

class BottomSliderView: UIView {
    
    weak var colorBallView: ColorBallView?
    var highlighted: Bool = false
    var width: CGFloat { return bounds.width }
    var height: CGFloat { return bounds.height }
    
    override func draw(_ rect: CGRect) {
        if let colorBallView = colorBallView {
            let ctx = UIGraphicsGetCurrentContext()!
            let center = CGPoint(x: bounds.width / 2, y: 0)
            let radius: CGFloat =  (bounds.width/2) - colorBallView.padding
            let startAngle: CGFloat = CGFloat(colorBallView.bMaxVal).degreesToRadians
            let endAngle: CGFloat = CGFloat(colorBallView.bMinVal).degreesToRadians
            
            ctx.beginPath()
            ctx.saveGState()
            
            //Track Path
            let track = UIBezierPath()
            track.addArc(withCenter: center, radius: radius - colorBallView.pTrackWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            ctx.addPath(track.cgPath)
            ctx.setLineCap(CGLineCap.round)
            ctx.setLineWidth(colorBallView.trackWidth)
            ctx.strokePath()
            
            ctx.restoreGState()
            ctx.saveGState()
            
            //progress Track
            let pEndDegree = min(max((colorBallView.bMinVal), colorBallView.bProgressValue), colorBallView.bMaxVal)
            let pEndAngleRad = CGFloat(pEndDegree).degreesToRadians
            let ptrack = UIBezierPath()
            ptrack.addArc(withCenter: center, radius: radius - (colorBallView.pTrackWidth/2), startAngle: startAngle, endAngle: CGFloat(pEndAngleRad), clockwise: false)
            ctx.setLineCap(CGLineCap.round)
            ctx.addPath(ptrack.cgPath)
            ctx.setLineWidth(colorBallView.pTrackWidth)
            ctx.strokePath()
            
            //Drawing gradient
            var colors: [CGColor]!
            let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
            var colorLocations: [CGFloat]?
            if colorBallView.isShadesOfWhite {
                colors = colorBallView.BSColorList
                colorLocations = [0.0, 0.5, 1.0]
            } else {
                colors = colorBallView.BColorList
                colorLocations = [0.125, 0.3, 0.4, 0.45, 0.65, 0.75, 0.875]
            }
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
            let gStartPoint = CGPoint(x: 0, y: bounds.width/2)
            let gEndPoint = CGPoint(x: bounds.width, y: bounds.width/2)
            
            
            //setting blend mode to sourceIn so it will draw only on the paths
            ctx.setBlendMode(CGBlendMode.sourceIn)
            
            //TODO: Add axial shading gradient insteed of linear gradient
            ctx.drawLinearGradient(gradient, start: gStartPoint, end: gEndPoint, options: [])
            
            ctx.restoreGState()
            ctx.saveGState()
            
            //Thumb
            let shadowHeight = 2 - (4 * ((pEndAngleRad - 0.5) / 2.1))
            let newRadius = radius + colorBallView.trackWidth/2 - colorBallView.thumbWidth/2
            let newX = center.x + (newRadius * cos(pEndAngleRad))
            let newY = center.y + (newRadius * sin(pEndAngleRad))
            let thumbRect = CGRect(x: newX - (colorBallView.thumbWidth/2 ), y: newY - (colorBallView.thumbWidth/2 ), width: colorBallView.thumbWidth, height: colorBallView.thumbWidth)
            let color: UIColor!
            if highlighted {
                let c = CGPoint(x: newX, y: newY)
                let pointInView = self.layer.convert(c, to: colorBallView.layer)
                let hueColor = colorBallView.getPixelColorAtPoint(point: pointInView)
                color = UIColor(red: CGFloat(hueColor.red)/255.0, green: CGFloat(hueColor.green)/255.0, blue: CGFloat(hueColor.blue)/255.0, alpha: 1.0)
                colorBallView.hueValues = (hueColor.red, hueColor.green, hueColor.blue)
                colorBallView.updateTrackingView()
            } else {
                let hueColor: UIColor  = UIColor(red: CGFloat(colorBallView.hueValues.0)/255.0, green: CGFloat(colorBallView.hueValues.1)/255.0, blue: CGFloat(colorBallView.hueValues.2)/255.0, alpha: 1.0)
                color = hueColor
            }
            let thumbPath = UIBezierPath(ovalIn: thumbRect)
            let shadowColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5)
            ctx.setShadow(offset:  CGSize(width: -2, height: shadowHeight), blur: 0.4, color: shadowColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            let thumbColor: UIColor = color.withAlphaComponent(1.0)
            ctx.setFillColor(thumbColor.cgColor)
            ctx.fillPath()
        }
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}



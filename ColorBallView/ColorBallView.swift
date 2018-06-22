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
open class ColorBallView: UIControl {
    
    //Settings
    open weak var delegate: ColorBallViewDelegate?
    var paddeding: CGFloat = 15.0
    var isTouchEnable: Bool = true
    
    @IBInspectable var shouldShowSlider: Bool = true { didSet { updateLayerFrames() } }
    
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
   
    @IBInspectable
    var bgColor: UIColor = #colorLiteral(red: 0.1689999998, green: 0.172999993, blue: 0.1659999937, alpha: 1) {
        didSet {
            updateLayerFrames()
        }
    }
    //Top slider
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
    
    @IBInspectable var tProgressValue: Double = 300 {
        didSet {
            tTrackLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    
    var ttrackColorList: [UIColor] = [UIColor]()
    
    @IBInspectable var bProgressValue: Double = 120 {
        didSet {
            bTrackLayer.setNeedsDisplay()
            colorBallLayer.setNeedsDisplay()
            dBallLayer.setNeedsDisplay()
        }
    }
    var bTrackColorList: [UIColor] = [UIColor]()
    
    
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
        if shouldShowSlider {
            //Top progress track
            tTrackLayer.colorBallView = self
            tTrackLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(tTrackLayer)
            
            //Bottom Progress track
            bTrackLayer.colorBallView = self
            bTrackLayer.contentsScale = UIScreen.main.scale
            layer.addSublayer(bTrackLayer)
        }
        
        //center color ball
        colorBallLayer.colorBallView = self
        colorBallLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(colorBallLayer)
        
        updateLayerFrames()
    }
    
    func updateLayerFrames() {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        //frams for defusion ball
        let dPadding: CGFloat = self.bounds.width - paddeding
        let dBallS = CGRect(x: dPadding, y: dPadding, width: self.bounds.width - (2 * dPadding), height: self.bounds.width - (2 * dPadding))
        dBallLayer.frame = dBallS
        dBallLayer.setNeedsDisplay()

        //frames for top progress tracking
        let tTrackFrame: CGRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height/2)
        tTrackLayer.frame = tTrackFrame
        tTrackLayer.setNeedsDisplay()
        
        //frames for bottom progress tracking
        let bTrackFrame: CGRect = CGRect(x: 0, y: bounds.height/2, width: bounds.width, height: bounds.height/2)
        bTrackLayer.frame = bTrackFrame
        bTrackLayer.setNeedsDisplay()
        
        //frams for center color ball
        let lPadding: CGFloat = self.bounds.width/3.6 - paddeding
        let lightColorS = CGRect(x: lPadding, y: lPadding, width: self.bounds.width - (2 * lPadding), height: self.bounds.width - (2 * lPadding))
        colorBallLayer.frame = lightColorS
        colorBallLayer.position = CGPoint(x: bounds.width/2, y: bounds.height/2)
        colorBallLayer.setNeedsDisplay()
        
        CATransaction.commit()
        
    }
    
    var previousLoaction = CGPoint()
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        //make the silder visible and decreace the width of the ball
        
        previousLoaction = touch.location(in: self)
        stopTracking()
        
        if colorBallLayer.frame.contains(previousLoaction) {
            colorBallLayer.highlighted = true
            //get the color on the touched point inside the ball
            trackingPonint = previousLoaction
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
                return true
            }
            stopTracking()
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
        stopTracking()
        return false
        
    }
    
    open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
       stopTracking()
    }
    
    open override func cancelTracking(with event: UIEvent?) {
        stopTracking()
    }
    
    func stopTracking() {
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
}


class ColorballLayer: CALayer {
    
    weak var colorBallView: ColorBallView?
    var  highlighted: Bool = false { didSet { setNeedsDisplay() } }
    var width: CGFloat  { return bounds.width }
    var height: CGFloat { return bounds.height }
    
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
            
            
            let trackingCenter: CGPoint = CGPoint(x: colorBallView.trackingPonint.x - anchorPoint.x , y: colorBallView.trackingPonint.y - anchorPoint.y)
            let tc = colorBallView.layer.convert(trackingCenter, to: self)
            
        
            let dist = distance(tc, center)
            
            if dist <= radius {
                let finalTcX:CGFloat = min(max(0, tc.x), width)
                let finalTcY:CGFloat = min(max(0, tc.y), height)
                print(finalTcX)
                print(finalTcY)
                ctx.restoreGState()
                self.masksToBounds = false
                ctx.addArc(center: CGPoint(x: finalTcX, y: finalTcY), radius: 8, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
                ctx.closePath()
                //ctx.setStrokeColor(UIColor.white.cgColor)
                ctx.setFillColor(UIColor.white.cgColor)
                //ctx.strokePath()
                ctx.fillPath()
            }
            
            
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
            let colors = [colorBallView.outsideColor.withAlphaComponent(alpaVale).cgColor, colorBallView.bgColor.withAlphaComponent(alpaVale).cgColor] as CFArray
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
    
    override func draw(in ctx: CGContext) {
        if let colorBallView = colorBallView {
            
            let center = CGPoint(x: bounds.width / 2, y: bounds.height)
            let radius: CGFloat = (bounds.width/2) - colorBallView.paddeding
            let startAngle: CGFloat = CGFloat(colorBallView.tMinVal).degreesToRadians
            let endAngle: CGFloat =  CGFloat((colorBallView.tMaxVal)).degreesToRadians
            ctx.beginPath()
           
            //Track
            let track = UIBezierPath()
            track.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            ctx.setLineWidth(colorBallView.trackWidth)
            ctx.setLineCap(CGLineCap.round)
            ctx.setStrokeColor(colorBallView.outsideColor.cgColor)
            ctx.move(to: CGPoint(x: 0, y: radius))
            ctx.addPath(track.cgPath)
            ctx.strokePath()
            let pEndDegree = min(max((colorBallView.tMinVal), colorBallView.tProgressValue), colorBallView.tMaxVal)
            let endAngleRad = CGFloat(pEndDegree).degreesToRadians
        
            //Progress track
            let ptrack = UIBezierPath()
            ptrack.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(endAngleRad), clockwise: true)
            ctx.setLineCap(CGLineCap.round)
            ctx.setLineWidth((colorBallView.pTrackWidth))
            ctx.setStrokeColor((colorBallView.insideColor.cgColor))
            ctx.move(to: CGPoint(x: 0, y: radius))
            ctx.addPath(ptrack.cgPath)
            ctx.strokePath()
            
            //Thumb
            let newX = center.x + (radius * cos(endAngleRad))
            let newY = center.y + (radius * sin(endAngleRad))
            let thumbRect = CGRect(x: newX - (colorBallView.thumbWidth/2 ), y: newY - (colorBallView.thumbWidth/2 ), width: colorBallView.thumbWidth, height: colorBallView.thumbWidth)
            let thumbPath = UIBezierPath(ovalIn: thumbRect)
            let shadowColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5)
            ctx.setShadow(offset:  CGSize(width: -2, height: -1), blur: 0.4, color: shadowColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.setFillColor(colorBallView.insideColor.cgColor)
            ctx.fillPath()
        }
    }
}

class BottomSliderLayer: CAShapeLayer {
    
    weak var colorBallView: ColorBallView?
    var highlighted: Bool = false
    var width: CGFloat { return bounds.width }
    var height: CGFloat { return bounds.height }

    override func draw(in ctx: CGContext) {
        if let colorBallView = colorBallView {
            
            //without gradient
            let center = CGPoint(x: bounds.width / 2, y: 0)
            let radius: CGFloat =  (bounds.width/2) - colorBallView.paddeding
            let startAngle: CGFloat = CGFloat(colorBallView.bMaxVal).degreesToRadians //  CGFloat((5 * Double.pi) / 6 )
            let endAngle: CGFloat = CGFloat(colorBallView.bMinVal).degreesToRadians  //CGFloat(( Double.pi) / 6)
            ctx.beginPath()

            //Track
            let track = UIBezierPath()
            track.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            ctx.setLineCap(CGLineCap.round)
            ctx.setLineWidth(colorBallView.trackWidth)
            ctx.setStrokeColor(colorBallView.outsideColor.cgColor)
            //ctx.setStrokeColor(colorBallView.bTrackColor.cgColor)
            ctx.addPath(track.cgPath)
            ctx.strokePath()

            let pEndDegree = min(max((colorBallView.bMinVal), colorBallView.bProgressValue), colorBallView.bMaxVal)
            let endAngleRad = CGFloat(pEndDegree).degreesToRadians

            //progress Track
            let ptrack = UIBezierPath()
            ptrack.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(endAngleRad), clockwise: false)
            ctx.setLineCap(CGLineCap.round)
            ctx.setLineWidth((colorBallView.pTrackWidth))
            //ctx.setStrokeColor((colorBallView.bProgressColor.cgColor))
            ctx.addPath(ptrack.cgPath)
            ctx.strokePath()

            //Thumb
            let newX = center.x + (radius * cos(endAngleRad))
            let newY = center.y + (radius * sin(endAngleRad))
            let thumbRect = CGRect(x: newX - (colorBallView.thumbWidth/2 ), y: newY - (colorBallView.thumbWidth/2 ), width: colorBallView.thumbWidth, height: colorBallView.thumbWidth)
            let thumbPath = UIBezierPath(ovalIn: thumbRect)
            let shadowColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5)
            ctx.setShadow(offset:  CGSize(width: -2, height: -1), blur: 0.4, color: shadowColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.setFillColor(colorBallView.outsideColor.cgColor)
            ctx.fillPath()
            
            
            //with gradient
            /*
            ctx.clear(bounds)
            //
            let center = CGPoint(x: bounds.width / 2, y: 0)
            let radius: CGFloat =  (bounds.width/2) - colorBallView.paddeding
            let startAngle: CGFloat = CGFloat(colorBallView.bMaxVal).degreesToRadians
            let endAngle: CGFloat = CGFloat(colorBallView.bMinVal).degreesToRadians
           
            ctx.saveGState()
            ctx.beginPath()
            
//            //Track
//            let track = UIBezierPath()
//            track.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
//
//            let trackShapeLayer = CAShapeLayer()
//            trackShapeLayer.path = track.cgPath
//            trackShapeLayer.lineWidth = colorBallView.trackWidth
//            trackShapeLayer.lineCap = "round"
//            trackShapeLayer.fillColor = UIColor.clear.cgColor
//            trackShapeLayer.strokeColor = UIColor.red.cgColor
//
//            //draw gradient
//            let trackGradient = CAGradientLayer()
//            trackGradient.frame = bounds
//            trackGradient.colors = [#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1).cgColor, #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1).cgColor, #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor, #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor, #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor]
//            trackGradient.startPoint = CGPoint(x: 0, y: 0.5)
//            trackGradient.endPoint = CGPoint(x: 1, y: 0.5)
//            trackGradient.locations = [0, 0.25, 0.5, 0.75, 1]
//            self.addSublayer(trackGradient)
//            trackGradient.mask = trackShapeLayer
            
            ctx.restoreGState()
            ctx.saveGState()
            let pEndDegree = min(max((colorBallView.bMinVal), colorBallView.bProgressValue), colorBallView.bMaxVal)
            let endAngleRad = CGFloat(pEndDegree).degreesToRadians
            
            
            //progress Track
            let ptrack = UIBezierPath()
            ptrack.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: CGFloat(endAngleRad), clockwise: false)
            
            let pTrackShapeLayer = CAShapeLayer()
            pTrackShapeLayer.path = ptrack.cgPath
            pTrackShapeLayer.lineWidth = colorBallView.pTrackWidth
            pTrackShapeLayer.lineCap = "round"
            pTrackShapeLayer.fillColor = UIColor.clear.cgColor
            pTrackShapeLayer.strokeColor = UIColor.red.cgColor
            
            //draw gradient
            let pTrackGradient = CAGradientLayer()
            pTrackGradient.frame = bounds
            pTrackGradient.colors = [#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1).cgColor, #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1).cgColor, #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor, #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor, #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1).cgColor]
            pTrackGradient.startPoint = CGPoint(x: 0, y: 0.5)
            pTrackGradient.endPoint = CGPoint(x: 1, y: 0.5)
            pTrackGradient.locations = [0, 0.25, 0.5, 0.75, 1]
            self.addSublayer(pTrackGradient)
            pTrackGradient.mask = pTrackShapeLayer
            
            ctx.restoreGState()
            
            //Thumb
            let newX = center.x + (radius * cos(endAngleRad))
            let newY = center.y + (radius * sin(endAngleRad))
            let thumbRect = CGRect(x: newX - (colorBallView.thumbWidth/2 ), y: newY - (colorBallView.thumbWidth/2 ), width: colorBallView.thumbWidth, height: colorBallView.thumbWidth)
            let thumbPath = UIBezierPath(ovalIn: thumbRect)
            let shadowColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 0.5)
            ctx.setShadow(offset:  CGSize(width: -2, height: 1), blur: 0.4, color: shadowColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.setFillColor(colorBallView.outsideColor.cgColor)
            ctx.fillPath()
            */
        }
    }
}


extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}

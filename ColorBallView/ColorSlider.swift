////
////  ColorSlider.swift
////  ColorBallView
////
////  Created by Iraniya Naynesh on 12/07/18.
////  Copyright © 2018 Iraniya. All rights reserved.
////
//
//import UIKit
//
//@IBDesignable
//class ColorSlider: UIView {
//    
//    var trackWidth: CGFloat = 5
//    var pTrackWidth: CGFloat = 20
//    var thumbWidth: CGFloat = 25
//    
//    var bMinVal: Double = 30
//    var bMaxVal: Double = 150
//    
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//        
//        let angle: CGFloat = CGFloat(180).degreesToRadians
//        layer.transform = CATransform3DMakeRotation(angle, 0.0, -1.0, 0.0)
//        let center = CGPoint(x: bounds.width / 2, y: 0)
//        let radius: CGFloat =  (bounds.width/2)
//        let startAngle: CGFloat = CGFloat(bMinVal).degreesToRadians
//        let endAngle: CGFloat = CGFloat(bMaxVal).degreesToRadians
//        let pEndAngle: CGFloat = CGFloat(90).degreesToRadians
//        
//        let centerRad  = radius - pTrackWidth/2
//        let startAngleRad = CGFloat(bMaxVal).degreesToRadians
//        let mindPointX = center.x + (centerRad * cos(startAngleRad))
//        let midPointY = center.y + (centerRad * sin(startAngleRad))
//        let midPoint: CGPoint = CGPoint(x: mindPointX, y: midPointY)
//        
//        let tCRad  = radius - pTrackWidth/2 + trackWidth/2
//        let endAngleRad = CGFloat(bMinVal).degreesToRadians
//        let endMidPointX = center.x + (tCRad * cos(endAngleRad))
//        let endMidPointY = center.y + (tCRad * sin(endAngleRad))
//        let endMidPoint: CGPoint = CGPoint(x: endMidPointX, y: endMidPointY)
//        
//        let track = UIBezierPath()
//        track.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
//        track.lineWidth = trackWidth
//        UIColor.red.setStroke()
//        track.stroke()
//        
//        let pTrack = UIBezierPath()
//        pTrack.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: pEndAngle, clockwise: true)
//        pTrack.lineWidth = pTrackWidth
//        UIColor.red.setStroke()
//        pTrack.stroke()
//        
//    }
//}
//
////extension FloatingPoint {
////    var degreesToRadians: Self { return self * .pi / 180 }
////    var radiansToDegrees: Self { return self * 180 / .pi }
////}

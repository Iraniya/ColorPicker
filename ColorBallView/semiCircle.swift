//
//  semiCircle.swift
//  ColorBallView
//
//  Created by Iraniya Naynesh on 21/06/18.
//  Copyright © 2018 Iraniya. All rights reserved.
//

import UIKit

class semiCircle: UIControl {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
   
    var width: CGFloat  { return bounds.width }
    var height: CGFloat { return bounds.height }
   
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        let center = CGPoint(x: width/2, y: height/2)
        let radius: CGFloat = ((width>height) ? height : width)/4
        
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
        path.close()
        path.addClip()
        context.addPath(path.cgPath)
       
        context.restoreGState()
        
        context.saveGState()
        
        let path3 = UIBezierPath()
        path3.addArc(withCenter: CGPoint(x: bounds.width, y: 0), radius: radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
        path3.close()
        path3.addClip()
        context.addPath(path3.cgPath)
        
        context.restoreGState()
        context.saveGState()
        
        let path2 = UIBezierPath()
        path2.addArc(withCenter: CGPoint(x: 0, y: 0), radius: radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: true)
        path2.close()
        path2.addClip()
        context.addPath(path2.cgPath)
        
        context.restoreGState()
        context.saveGState()
        
        let path4 = UIBezierPath()
        path4.addArc(withCenter: CGPoint(x: 0, y: bounds.height), radius: radius, startAngle: 0, endAngle: CGFloat(2*Double.pi), clockwise: false)
        path4.close()
        path4.addClip()
        context.addPath(path4.cgPath)
//        //context.fillPath()
//        context.fillPath()
        
//        context.restoreGState()
        
        let colors = [#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1).cgColor, #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1).cgColor, #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1).cgColor, #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1).cgColor, #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1).cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations: [CGFloat] = [0.0, 0.25, 0.5, 0.75, 1.0]
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: colorLocations)!
        let startPoint = CGPoint(x: 0, y: 0.5)
        let endPoint = CGPoint(x: bounds.width, y: 0.5)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
        
    }
    
    var previousLoaction = CGPoint()
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        
        previousLoaction = touch.location(in: self)
        getAngle(fromPoint: previousLoaction)
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousLoaction = touch.location(in: self)
        getAngle(fromPoint: previousLoaction)
        return true
    }
    
    func getAngle(fromPoint point: CGPoint) {
        var angle: CGFloat  = 0
        print(point)
        print(center)
        let centerC = CGPoint(x: bounds.width/2, y: bounds.height/2)
        print("centerC \(centerC)")
        angle = CGFloat(atan2(point.y - centerC.y , -(point.x - centerC.x))).radiansToDegrees
        print("angle \(angle)")
    }
    
}

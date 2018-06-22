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
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        //let context = UIGraphicsGetCurrentContext()
        //context?.rotate(by: CGFloat(5).degreesToRadians)
        
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let startAngle = CGFloat(150).degreesToRadians
        let end = CGFloat(30).degreesToRadians
        let path = UIBezierPath()
        path.addArc(withCenter: center, radius: bounds.width/2, startAngle: startAngle, endAngle: end, clockwise: false)
        path.lineWidth = 10
        UIColor.green.setStroke()
        path.stroke()
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

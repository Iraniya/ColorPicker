//
//  AngleGradientBorderLayer.swift
//  ColorBallView
//
//  Created by Iraniya Naynesh on 27/06/18.
//  Copyright © 2018 Iraniya. All rights reserved.
//

import UIKit

class AngleGradientBorderLayer: AngleGradientLayer {
    
    // Properties
    var gradientBorderWidth: CGFloat = 1
    
    // Override to add a border shape to AngleGradientLayer.
    override func draw(in ctx: CGContext) {
        // Draw a shape that fills the view minus the width of your final border.
        // This can be any shape you want to make a border out of.
        // This example draws a circle.
        
        
        
        
        
        let shapePath = UIBezierPath(roundedRect: bounds.insetBy(dx: gradientBorderWidth, dy: gradientBorderWidth), cornerRadius: bounds.height/2)
        
        // Copy the path of the shape and turn it into a stroke.
   
        let shapeCopyPath = shapePath.cgPath.copy(strokingWithWidth: 4.0, lineCap: CGLineCap.round, lineJoin: CGLineJoin.bevel, miterLimit: 0.0)
        
        ctx.saveGState()
        // Add the stroked path to the context and clip to it.
        
        ctx.addPath(shapePath.cgPath)
        ctx.clip()
        
        // Call our super class's (AngleGradientLayer) #drawInContext
        // which will do the work to create the gradient.
        super.draw(in: ctx)
        ctx.restoreGState()
    }
}











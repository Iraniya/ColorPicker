//
//  ViewController.swift
//  ColorBallView
//
//  Created by Iraniya Naynesh on 15/06/18.
//  Copyright © 2018 Iraniya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var colorViewWidth1: NSLayoutConstraint!
    @IBOutlet weak var colorViewWidth2: NSLayoutConstraint!
    @IBOutlet weak var tempColorBox: UIView!
    @IBOutlet weak var colorBallView: ColorBallView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
       colorBallView.delegate = self
    }
    
    @IBAction func changeFrames(_ sender: UIButton!) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1.0) {
            self.colorViewWidth2.isActive = false
            self.colorViewWidth1.isActive = true
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func changeFramesAgian(_ sender: UIButton!) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1.0) {
            self.colorViewWidth1.isActive = false
            self.colorViewWidth2.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
}

extension ViewController: ColorBallViewDelegate {
    
    func colorBallView(_ colorBall: ColorBallView, withSelectedColorValues selectedRGB: (Int, Int, Int), andHueColor hueColor:(Int, Int, Int), withBrightness brightness: Int, userInteractionFinished: Bool, hueAngle: Double, brightnessAngle: Double) {
        print("colorsValues \(selectedRGB)")
        print("brightness \(brightness)")
        print("userInteractionFinished \(userInteractionFinished)")
        print("hueAngle \(hueAngle)")
        print("brightnessAngle \(brightnessAngle)")
        let color: UIColor = UIColor(red: CGFloat(hueColor.0)/255.0, green: CGFloat(hueColor.1)/255.0, blue: CGFloat(hueColor.2)/255.0, alpha: 1.0)
        
        tempColorBox.backgroundColor = color
    }
    
}

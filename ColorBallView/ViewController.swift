//
//  ViewController.swift
//  ColorBallView
//
//  Created by Iraniya Naynesh on 15/06/18.
//  Copyright © 2018 Iraniya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var colorBallView: ColorBallView!
    @IBOutlet weak var tempColorBox: UIView!
    @IBOutlet weak var colorViewWidth1: NSLayoutConstraint!
    @IBOutlet weak var colorViewWidth2: NSLayoutConstraint!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        colorBallView.touchEnable = true
        colorBallView.delegate = self
    }
    
}


//MARK: Color view Delegates

extension ViewController: ColorBallViewDelegate {
    func colorBallView(_ colorBall: ColorBallView, withSelectedColorValues selectedRGB: (Int, Int, Int), andHueColor hueColor: (Int, Int, Int), withBrightness brightness: Int, userInteractionFinished: Bool, hueAngle: Double, brightnessAngle: Double) {
        
        print("colorsValues \(selectedRGB)")
        print("brightness \(brightness)")
        print("userInteractionFinished \(userInteractionFinished)")
        print("hueAngle \(hueAngle)")
        print("brightnessAngle \(brightnessAngle)")
        let color: UIColor = UIColor(red: CGFloat(selectedRGB.0)/255.0, green: CGFloat(selectedRGB.1)/255.0, blue: CGFloat(selectedRGB.2)/255.0, alpha: 1.0)
        
        tempColorBox.backgroundColor = color
    }
}

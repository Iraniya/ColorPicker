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
        // Do any additional setup after loading the view, typically from a nib.
        
        colorBallView.touchEnable = true
        colorBallView.delegate = self
        
    }
    
    @IBAction func changeFrames(_ sender: UIButton!) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1.0) {
            self.colorViewWidth2.isActive = false
            self.colorViewWidth1.isActive = true
            self.view.layoutIfNeeded()
//            self.colorBallView.layer.bounds = self.containerView.bounds
//            self.colorBallView.layer.position = self.containerView.center
        }
       
    }
    
    @IBAction func changeFramesAgian(_ sender: UIButton!) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 1.0) {
            self.colorViewWidth1.isActive = false
            self.colorViewWidth2.isActive = true
            self.view.layoutIfNeeded()
//            self.colorBallView.layer.bounds = self.containerView.bounds
//            self.colorBallView.layer.position = self.containerView.center
            
        }
    }
}


//MARK: Glo Color view Delegates

extension ViewController: ColorBallViewDelegate {
    func colorBallView(_ colorBall: ColorBallView, withColorValues colorsValues: (Int, Int, Int, Int), withBrightness brightness: Int, userInteractionFinished: Bool, hueAngle: Double, brightnessAngle: Double) {
        
        print("colorsValues \(colorsValues)")
        print("brightness \(brightness)")
        print("userInteractionFinished \(userInteractionFinished)")
        print("hueAngle \(hueAngle)")
        print("brightnessAngle \(brightnessAngle)")
        let color: UIColor = UIColor(red: CGFloat(colorsValues.0)/255.0, green: CGFloat(colorsValues.1)/255.0, blue: CGFloat(colorsValues.2)/255.0, alpha: CGFloat(colorsValues.3)/255.0)
        
        tempColorBox.backgroundColor = color
    }
}

//
//  ViewController.swift
//  ColorBallView
//
//  Created by Iraniya Naynesh on 15/06/18.
//  Copyright © 2018 Iraniya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var colorBallView: ColorBallView!
    @IBOutlet weak var tempColorBox: UIView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        colorBallView.touchEnable = true
        colorBallView.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

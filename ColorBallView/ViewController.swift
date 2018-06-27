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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        colorBallView.touchEnable = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


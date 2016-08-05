//
//  ViewController.swift
//  VKEBExample
//
//  Created by Vladislav Kovalyov on 8/4/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    var buttonRight: VKExpandableButton!
    
    @IBOutlet weak var buttonLeft:  VKExpandableButton!
    @IBOutlet weak var buttonDown: VKExpandableButton!
    @IBOutlet weak var buttonUp: VKExpandableButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Add manually VKExpandableButton with text content via code
        // Direction: RIGHT (from left to right)
        self.buttonRight = VKExpandableButton(frame: CGRectMake(16, 28, 80, 44))
        self.buttonRight.direction      = .Right
        self.buttonRight.options        = ["Auto", "On", "Off"]
        self.buttonRight.currentValue   = self.buttonRight.options[0]
        self.buttonRight.cornerRadius   = self.buttonRight.frame.size.height / 2
        
        self.buttonRight.optionSelectionBlock = {
            index in
            print("[Right] Did select option at index: \(index)")
        }
        
        self.view.addSubview(self.buttonRight)
        
        // Customized VKExpandableButton with UIImage content
        // Direction: LEFT (from right to left)
        self.buttonLeft.direction      = .Left
        self.buttonLeft.options        = [UIImage(named: "icon1")!, UIImage(named: "icon2")!, UIImage(named: "icon3")!]
        self.buttonLeft.currentValue   = self.buttonLeft.options[2]
        self.buttonLeft.cornerRadius   = self.buttonLeft.frame.size.height / 2
        self.buttonLeft.imageInsets    = UIEdgeInsetsMake(12, 12, 12, 12)
        self.buttonLeft.selectionColor = UIColor(red: 75.0/256.0, green: 178.0/256.0, blue: 174.0/256.0, alpha: 1.0)
        self.buttonLeft.buttonBackgroundColor = UIColor(red: 44.0/256.0, green: 62.0/256.0, blue: 80.0/256.0, alpha: 1.0)
        self.buttonLeft.expandedButtonBackgroundColor = self.buttonLeft.buttonBackgroundColor
        
        self.buttonLeft.optionSelectionBlock = {
            index in
            print("[Left] Did select cat at index: \(index)")
        }
        
        // Icons made by http://www.freepik.com from http://www.flaticon.com is licensed by http://creativecommons.org/licenses/by/3.0/
        
        // VKExpandableButton with text content
        // Direction: DOWN (from top to bottom)
        self.buttonDown.direction      = .Down
        self.buttonDown.options        = ["Auto", "On", "Off"]
        self.buttonDown.currentValue   = self.buttonRight.options[1]
        
        self.buttonDown.optionSelectionBlock = {
            index in
            print("[Down] Did select option at index: \(index)")
        }
        
        // VKExpandableButton with mixed content
        // Direction: UP (from bottom to top)
        self.buttonUp.direction      = .Up
        self.buttonUp.options        = ["Dog", UIImage(named: "icon2")!, "Mouse"]
        self.buttonUp.currentValue   = self.buttonUp.options[0]
        self.buttonUp.optionSelectionBlock = {
            index in
            print("[Up] Did select option at index: \(index)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


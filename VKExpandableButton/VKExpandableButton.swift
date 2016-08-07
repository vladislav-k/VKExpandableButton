//
// VKExpandableButton.swift
//
// Created by Vladislav Kovalyov on 8/4/16.
// Copyright © 2016 WOOPSS.com http://woopss.com/ All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

typealias OptionSelectionBlock = (index: Int) -> Void

enum VKExpandableButtonDirection
{
    case Up
    case Right
    case Down
    case Left
}

// MARK: - Init
@IBDesignable
class VKExpandableButton: UIView
{
// MARK: Declared properties
    var options: [AnyObject]!
    
    var direction: VKExpandableButtonDirection = .Right
    
    var textFont  = UIFont.systemFontOfSize(15.0)
    var textColor = UIColor.whiteColor(){
        didSet {
            self.button.setTitleColor(self.textColor, forState: .Normal)
        }
    }
    
    var expandedTextColor = UIColor.whiteColor()
    
    var autoHideOptions = true
    var animationDuration: NSTimeInterval = 0.275
    private var minOptionSize: CGFloat = 60
    
    var imageInsets: UIEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6)
    {
        didSet {
            self.button.imageEdgeInsets = imageInsets
        }
    }
    
    var buttonBackgroundColor = UIColor.lightGrayColor()
    {
        didSet {
            self.button.backgroundColor = buttonBackgroundColor
        }
    }
    
    var expandedButtonBackgroundColor = UIColor.lightGrayColor()
    
    var selectionColor = UIColor.grayColor()
    {
        didSet {
            self.button.setBackgroundImage(UIImage.imageWithColor(selectionColor), forState: .Highlighted)
        }
    }
    
    var cornerRadius: CGFloat = 0
    {
        didSet {
            self.button.layer.cornerRadius      = cornerRadius
            self.optionsView.layer.cornerRadius = cornerRadius
        }
    }
    
    var currentValue: AnyObject!
    {
        didSet
        {
            if currentValue is String
            {
                self.button.setTitle(currentValue as? String, forState: .Normal)
                self.button.setImage(nil, forState: .Normal)
            }
            else if currentValue is UIImage
            {
                self.button.setImage(currentValue as? UIImage, forState: .Normal)
                self.button.setTitle(nil, forState: .Normal)
            }
        }
    }
    
    var optionSelectionBlock: OptionSelectionBlock?
    
    private var button      = UIButton()
    private var optionsView = UIView()
    
// MARK: Init
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.button.frame  = self.bounds
    }
    
    /**
        Perform initial setup of `VKExpandableButton` view
    */
    private func setupView()
    {
        self.button.frame               = self.bounds
        self.button.titleLabel?.font    = self.textFont
        self.button.layer.cornerRadius  = self.cornerRadius
        self.button.backgroundColor     = self.buttonBackgroundColor
        
        self.button.imageView?.contentMode  = .ScaleAspectFit
        self.button.imageEdgeInsets         = self.imageInsets
        
        self.button.titleLabel?.textAlignment = .Center
        self.button.setTitleColor(self.textColor, forState: .Normal)
        
        self.button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.button.setBackgroundImage(UIImage.imageWithColor(selectionColor), forState: .Highlighted)
        self.button.addTarget(self, action: #selector(VKExpandableButton.showOptions), forControlEvents: .TouchUpInside)
        
        self.addSubview(self.button)
        
        self.backgroundColor = UIColor.clearColor()
        self.button.layer.masksToBounds      = true
        self.optionsView.layer.masksToBounds = true
    }
}

// MARK: - Public methods
extension VKExpandableButton
{
    /**
        Show options view
    */
    func showOptions()
    {
        // Create `optionsView`
        self.optionsView.frame           = self.frame
        self.optionsView.backgroundColor = self.button.backgroundColor
        
        var desiredOrigin: CGFloat = 0
        let initialWidth = self.minOptionSize > self.button.bounds.size.width ? self.minOptionSize : self.button.bounds.size.width
        var i = 0
        
        // Create buttons for each option
        for option in self.options
        {
            // Prepare frame
            var frame = CGRectMake(desiredOrigin, 0, initialWidth, optionsView.frame.size.height)
            
            if self.direction == .Up || self.direction == .Down
            {
                frame = CGRectMake(0, desiredOrigin, initialWidth, optionsView.frame.size.height)
            }
            
            let button = UIButton(frame: frame)
            
            // Configure button with UIImage option
            if option is UIImage
            {
                button.setImage(option as? UIImage, forState: .Normal)
                button.imageView?.contentMode   = .ScaleAspectFit
                button.imageEdgeInsets          = self.imageInsets
            }
            // Configure button with String option
            else if option is String
            {
                let textLength = (option as! NSString).sizeWithAttributes([NSFontAttributeName : self.textFont]).width
                
                if textLength > self.minOptionSize && textLength > self.button.bounds.size.width
                {
                    button.frame.size.width = textLength
                }
                
                button.setTitle(option as? String, forState: .Normal)
                button.setTitleColor(self.expandedTextColor, forState: .Normal)
            }
            else
            {
                // Show Unknown option type
                button.setTitle("UNKNOWN_TYPE", forState: .Normal)
                button.setTitleColor(UIColor.redColor(), forState: .Normal)
            }
            
            // Configure button
            button.titleLabel?.font                      = self.textFont
            button.titleLabel?.textAlignment             = .Center
            button.backgroundColor                       = UIColor.clearColor()
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            
            button.setBackgroundImage(UIImage.imageWithColor(self.selectionColor), forState: .Highlighted)
            button.addTarget(self, action: #selector(VKExpandableButton.onOptionButtonAction), forControlEvents: .TouchUpInside)
            button.tag = i
            
            // Add button to 'optionView'
            self.optionsView.addSubview(button)
            
            // Prepare frame and index for next button
            desiredOrigin += self.direction == .Up || self.direction == .Down ? button.frame.size.height : button.frame.size.width
            i += 1
        }
        
        self.superview?.addSubview(optionsView)
        
        let size = desiredOrigin
        
        // Show 'optionView'
        UIView.animateWithDuration(self.animationDuration)
        {
            self.optionsView.backgroundColor = self.expandedButtonBackgroundColor
            self.optionsView.frame           = self.frame(size: size, direction: self.direction)
        }
    }
    
    /**
        Close options view
        - Parameter selectedIndex: Index of selected option button
    */
    func hideOptions(selectedIndex: Int = 0)
    {
        // Hide all options buttons except of selected one
        UIView.animateWithDuration(self.animationDuration / 2)
        {
            for view in self.optionsView.subviews
            {
                if view.tag != selectedIndex
                {
                    view.alpha = 0
                }
            }
        }
        
        // Hide
        UIView.animateWithDuration(self.animationDuration, animations:
        {
            self.optionsView.backgroundColor = self.buttonBackgroundColor
            self.optionsView.frame           = self.frame
        })
        {
            (completed) in
            
            // Remove from superview
            for view in self.optionsView.subviews
            {
                view.removeFromSuperview()
            }
            
            self.optionsView.removeFromSuperview()
        }
    }
}

// MARK: - Private
extension VKExpandableButton
{
    /**
        Get frame for specific direction and final size of `optionView`
        - Parameter size: Final size of `optionView`
        - Parameter direction: Direct of `optionView`
        - Returns: `CGRect` frame for open state of `optionView`
    */
    private func frame(size size: CGFloat, direction: VKExpandableButtonDirection) -> CGRect
    {
        switch direction
        {
        case .Up:
            return CGRectMake(self.frame.origin.x, self.frame.maxY - size, self.frame.size.width, size)
            
        case .Right:
            return CGRectMake(self.frame.minX, self.frame.origin.y, size, self.frame.size.height)

        case .Down:
            return CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, size)

        case .Left:
            return CGRectMake(self.frame.maxX - size, self.frame.origin.y, size, self.frame.size.height)
        }
    }
    
    /**
        Selector of `self.button`
    */
    @objc private func onButtonAction(sender: UIButton)
    {
        self.showOptions()
    }
    
    /**
        Selector for buttons from `optionView`
    */
    @objc private func onOptionButtonAction(sender: UIButton)
    {
        // Update selected value
        self.currentValue = self.options[sender.tag]
        
        // Perform completion block
        if let completionBlock = self.optionSelectionBlock
        {
            completionBlock(index: sender.tag)
        }
        
        // Close options view if it is required
        if self.autoHideOptions
        {
            UIView.animateWithDuration(self.animationDuration, animations:
            {
                sender.frame = CGRectMake(0, 0, self.button.frame.size.width, self.button.frame.size.height)
            })
            
            self.hideOptions(sender.tag)
        }
    }
}

// MARK: - Utils
extension UIImage
{
    /**
        Create image from specific `UIColor`
        - Parameter color: Specific color
        - Returns: `UIImage` object filled by specific color
    */
    private class func imageWithColor(color: UIColor) -> UIImage
    {
        let size = CGSize(width: 64, height: 64)
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
//
//  VKExpandableButton.swift
//  VKEBExample
//
//  Created by Vladislav Kovalyov on 8/4/16.
//  Copyright © 2016 Vladislav Kovalyov. All rights reserved.
//

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
    var options: [AnyObject]!
    
    var direction: VKExpandableButtonDirection = .Right
    
    var textFont  = UIFont.systemFontOfSize(15.0)
    var textColor = UIColor.whiteColor()
    
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
            self.button.setBackgroundImage(VKExpandableButton.imageWithColor(selectionColor), forState: .Highlighted)
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
            }
            else if currentValue is UIImage
            {
                self.button.setImage(currentValue as? UIImage, forState: .Normal)
            }
        }
    }
    
    var optionSelectionBlock: OptionSelectionBlock?
    
    private var button      = UIButton()
    private var optionsView = UIView()
    
// MARK: - Init
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
        
        self.button.setBackgroundImage(VKExpandableButton.imageWithColor(selectionColor), forState: .Highlighted)
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
            var frame = CGRectMake(desiredOrigin, 0, initialWidth, optionsView.frame.size.height)
            
            if self.direction == .Up || self.direction == .Down
            {
                frame = CGRectMake(0, desiredOrigin, initialWidth, optionsView.frame.size.height)
            }
            
            let button = UIButton(frame: frame)
            
            if option is UIImage
            {
                button.setImage(option as? UIImage, forState: .Normal)
                button.imageView?.contentMode = .ScaleAspectFit
                button.imageEdgeInsets = self.imageInsets
            }
            else if option is String
            {
                let textLength = (option as! NSString).sizeWithAttributes([NSFontAttributeName : self.textFont]).width
                
                if textLength > self.minOptionSize && textLength > self.button.bounds.size.width
                {
                    button.frame.size.width = textLength
                }
                
                button.setTitle(option as? String, forState: .Normal)
                button.setTitleColor(self.textColor, forState: .Normal)
            }
            else
            {
                // Unknown type
                button.setTitle("UNKNOWN_TYPE", forState: .Normal)
                button.setTitleColor(UIColor.redColor(), forState: .Normal)
            }
            
            button.titleLabel?.font                      = self.textFont
            button.titleLabel?.textAlignment             = .Center
            button.backgroundColor                       = UIColor.clearColor()
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            
            button.setBackgroundImage(VKExpandableButton.imageWithColor(self.selectionColor), forState: .Highlighted)
            button.addTarget(self, action: #selector(VKExpandableButton.onOptionButtonAction), forControlEvents: .TouchUpInside)
            button.tag = i
            
            self.optionsView.addSubview(button)
            
            desiredOrigin += self.direction == .Up || self.direction == .Down ? button.frame.size.height : button.frame.size.width
            i += 1
        }
        
        self.superview?.addSubview(optionsView)
        
        let size = desiredOrigin
        
        UIView.animateWithDuration(self.animationDuration)
        {
            self.optionsView.backgroundColor = self.expandedButtonBackgroundColor
            self.optionsView.frame           = self.frame(size: size, direction: self.direction)
        }
    }
    
    func hideOptions()
    {
        UIView.animateWithDuration(self.animationDuration, animations:
        {
            self.optionsView.backgroundColor = self.buttonBackgroundColor
            self.optionsView.frame           = self.frame
        })
        {
            (completed) in
            
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
    
    @objc private func onButtonAction(sender: UIButton)
    {
        self.showOptions()
    }
    
    @objc private func onOptionButtonAction(sender: UIButton)
    {
        self.currentValue = self.options[sender.tag]
        
        if let completionBlock = self.optionSelectionBlock
        {
            completionBlock(index: sender.tag)
        }
        
        if self.autoHideOptions
        {
            UIView.animateWithDuration(self.animationDuration, animations:
            {
                sender.frame = CGRectMake(0, 0, self.button.frame.size.width, self.button.frame.size.height)
            })
            
            self.hideOptions()
        }
    }
}

// MARK: - Utils
extension VKExpandableButton
{
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
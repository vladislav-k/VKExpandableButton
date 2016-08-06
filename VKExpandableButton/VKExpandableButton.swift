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
    case up
    case right
    case down
    case left
}

// MARK: - Init
@IBDesignable
class VKExpandableButton: UIView
{
    var options: [AnyObject]!
    
    var direction: VKExpandableButtonDirection = .right
    
    var textFont  = UIFont.systemFont(ofSize: 15.0)
    var textColor = UIColor.white()
    
    var autoHideOptions = true
    var animationDuration: TimeInterval = 0.275
    private var minOptionSize: CGFloat = 60
    
    var imageInsets: UIEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6)
    {
        didSet {
            self.button.imageEdgeInsets = imageInsets
        }
    }
    
    var buttonBackgroundColor = UIColor.lightGray()
    {
        didSet {
            self.button.backgroundColor = buttonBackgroundColor
        }
    }
    
    var expandedButtonBackgroundColor = UIColor.lightGray()
    
    var selectionColor = UIColor.gray()
    {
        didSet {
            self.button.setBackgroundImage(VKExpandableButton.imageWithColor(selectionColor), for: .highlighted)
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
                self.button.setTitle(currentValue as? String, for: UIControlState())
            }
            else if currentValue is UIImage
            {
                self.button.setImage(currentValue as? UIImage, for: UIControlState())
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
        
        self.button.imageView?.contentMode  = .scaleAspectFit
        self.button.imageEdgeInsets         = self.imageInsets
        
        self.button.titleLabel?.textAlignment = .center
        self.button.setTitleColor(self.textColor, for: UIControlState())
        
        self.button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.button.setBackgroundImage(VKExpandableButton.imageWithColor(selectionColor), for: .highlighted)
        self.button.addTarget(self, action: #selector(VKExpandableButton.showOptions), for: .touchUpInside)
        
        self.addSubview(self.button)
        
        self.backgroundColor = UIColor.clear()
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
            var frame = CGRect(x: desiredOrigin, y: 0, width: initialWidth, height: optionsView.frame.size.height)
            
            if self.direction == .up || self.direction == .down
            {
                frame = CGRect(x: 0, y: desiredOrigin, width: initialWidth, height: optionsView.frame.size.height)
            }
            
            let button = UIButton(frame: frame)
            
            if option is UIImage
            {
                button.setImage(option as? UIImage, for: UIControlState())
                button.imageView?.contentMode = .scaleAspectFit
                button.imageEdgeInsets = self.imageInsets
            }
            else if option is String
            {
                let textLength = (option as! NSString).size(attributes: [NSFontAttributeName : self.textFont]).width
                
                if textLength > self.minOptionSize && textLength > self.button.bounds.size.width
                {
                    button.frame.size.width = textLength
                }
                
                button.setTitle(option as? String, for: UIControlState())
                button.setTitleColor(self.textColor, for: UIControlState())
            }
            else
            {
                // Unknown type
                button.setTitle("UNKNOWN_TYPE", for: UIControlState())
                button.setTitleColor(UIColor.red(), for: UIControlState())
            }
            
            button.titleLabel?.font                      = self.textFont
            button.titleLabel?.textAlignment             = .center
            button.backgroundColor                       = UIColor.clear()
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            
            button.setBackgroundImage(VKExpandableButton.imageWithColor(self.selectionColor), for: .highlighted)
            button.addTarget(self, action: #selector(VKExpandableButton.onOptionButtonAction), for: .touchUpInside)
            button.tag = i
            
            self.optionsView.addSubview(button)
            
            desiredOrigin += self.direction == .up || self.direction == .down ? button.frame.size.height : button.frame.size.width
            i += 1
        }
        
        self.superview?.addSubview(optionsView)
        
        let size = desiredOrigin
        
        UIView.animate(withDuration: self.animationDuration)
        {
            self.optionsView.backgroundColor = self.expandedButtonBackgroundColor
            self.optionsView.frame           = self.frame(size: size, direction: self.direction)
        }
    }
    
    func hideOptions()
    {
        UIView.animate(withDuration: self.animationDuration, animations:
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
    private func frame(size: CGFloat, direction: VKExpandableButtonDirection) -> CGRect
    {
        switch direction
        {
        case .up:
            return CGRect(x: self.frame.origin.x, y: self.frame.maxY - size, width: self.frame.size.width, height: size)
            
        case .right:
            return CGRect(x: self.frame.minX, y: self.frame.origin.y, width: size, height: self.frame.size.height)

        case .down:
            return CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: size)

        case .left:
            return CGRect(x: self.frame.maxX - size, y: self.frame.origin.y, width: size, height: self.frame.size.height)
        }
    }
    
    @objc private func onButtonAction(_ sender: UIButton)
    {
        self.showOptions()
    }
    
    @objc private func onOptionButtonAction(_ sender: UIButton)
    {
        self.currentValue = self.options[sender.tag]
        
        if let completionBlock = self.optionSelectionBlock
        {
            completionBlock(index: sender.tag)
        }
        
        if self.autoHideOptions
        {
            UIView.animate(withDuration: self.animationDuration, animations:
            {
                sender.frame = CGRect(x: 0, y: 0, width: self.button.frame.size.width, height: self.button.frame.size.height)
            })
            
            self.hideOptions()
        }
    }
}

// MARK: - Utils
extension VKExpandableButton
{
    private class func imageWithColor(_ color: UIColor) -> UIImage
    {
        let size = CGSize(width: 64, height: 64)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

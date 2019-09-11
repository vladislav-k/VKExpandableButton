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

typealias OptionSelectionBlock = (_ index: Int) -> Void

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
    var options: [Any]!
    
    var direction: VKExpandableButtonDirection = .Right
    
    var textFont  = UIFont.systemFont(ofSize: 15.0)
    var textColor = UIColor.white{
        didSet {
            self.button.setTitleColor(self.textColor, for: .normal)
        }
    }
    
    var expandedTextColor = UIColor.white
    
    var autoHideOptions = true
    var animationDuration: TimeInterval = 0.275
    private var minOptionSize: CGFloat = 60
    
    var imageInsets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    {
        didSet {
            self.button.imageEdgeInsets = imageInsets
        }
    }
    
    var buttonBackgroundColor = UIColor.lightGray
    {
        didSet {
            self.button.backgroundColor = buttonBackgroundColor
        }
    }
    
    var expandedButtonBackgroundColor = UIColor.lightGray
    
    var selectionColor = UIColor.gray
    {
        didSet {
            self.button.setBackgroundImage(UIImage.image(color: selectionColor), for: .highlighted)
        }
    }
    
    var cornerRadius: CGFloat = 0
    {
        didSet {
            self.button.layer.cornerRadius      = cornerRadius
            self.optionsView.layer.cornerRadius = cornerRadius
        }
    }
    
    var currentValue: Any!
    {
        didSet
        {
            if currentValue is String
            {
                self.button.setTitle(currentValue as? String, for: .normal)
                self.button.setImage(nil, for: .normal)
            }
            else if currentValue is UIImage
            {
                self.button.setImage(currentValue as? UIImage, for: .normal)
                self.button.setTitle(nil, for: .normal)
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
        
        self.button.imageView?.contentMode  = .scaleAspectFit
        self.button.imageEdgeInsets         = self.imageInsets
        
        self.button.titleLabel?.textAlignment = .center
        self.button.setTitleColor(self.textColor, for: .normal)
        
        self.button.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.button.setBackgroundImage(UIImage.image(color: selectionColor), for: .highlighted)
        self.button.addTarget(self, action: #selector(VKExpandableButton.showOptions), for: .touchUpInside)
        
        self.addSubview(self.button)
        
        self.backgroundColor = .clear
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
    @objc func showOptions()
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
            var frame = CGRect(x: desiredOrigin, y: 0, width: initialWidth, height: optionsView.frame.size.height)
            
            if self.direction == .Up || self.direction == .Down
            {
                frame = CGRect(x: 0, y: desiredOrigin, width: initialWidth, height: optionsView.frame.size.height)
            }
            
            let button = UIButton(frame: frame)
            
            // Configure button with UIImage option
            if option is UIImage
            {
                button.setImage(option as? UIImage, for: .normal)
                button.imageView?.contentMode   = .scaleAspectFit
                button.imageEdgeInsets          = self.imageInsets
            }
            // Configure button with String option
            else if option is String
            {
                let textLength = (option as! NSString).size(withAttributes: [NSAttributedString.Key.font : self.textFont]).width
                
                if textLength > self.minOptionSize && textLength > self.button.bounds.size.width
                {
                    button.frame.size.width = textLength
                }
                
                button.setTitle(option as? String, for: .normal)
                button.setTitleColor(self.expandedTextColor, for: .normal)
            }
            else
            {
                // Show Unknown option type
                button.setTitle("UNKNOWN_TYPE", for: .normal)
                button.setTitleColor(UIColor.red, for: .normal)
            }
            
            // Configure button
            button.titleLabel?.font                      = self.textFont
            button.titleLabel?.textAlignment             = .center
            button.backgroundColor                       = .clear
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            
            button.setBackgroundImage(UIImage.image(color: self.selectionColor), for: .highlighted)
            button.addTarget(self, action: #selector(VKExpandableButton.onOptionButtonAction), for: .touchUpInside)
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
        UIView.animate(withDuration: self.animationDuration)
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
        UIView.animate(withDuration: self.animationDuration / 2)
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
        UIView.animate(withDuration: self.animationDuration, animations:
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
    private func frame(size: CGFloat, direction: VKExpandableButtonDirection) -> CGRect
    {
        switch direction
        {
        case .Up:
            return CGRect(x: self.frame.origin.x, y: self.frame.maxY - size, width: self.frame.size.width, height: size)
            
        case .Right:
            return CGRect(x: self.frame.minX, y: self.frame.origin.y, width: size, height: self.frame.size.height)

        case .Down:
            return CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: size)

        case .Left:
            return CGRect(x: self.frame.maxX - size, y: self.frame.origin.y, width: size, height: self.frame.size.height)
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
            completionBlock(sender.tag)
        }
        
        // Close options view if it is required
        if self.autoHideOptions
        {
            UIView.animate(withDuration: self.animationDuration, animations:
            {
                sender.frame = CGRect(x: 0, y: 0, width: self.button.frame.size.width, height: self.button.frame.size.height)
            })
            
            self.hideOptions(selectedIndex: sender.tag)
        }
    }
}

// MARK: - Utils
extension UIImage
{
    /**
        Create image with specific `UIColor`
        - Parameter color: Color
        - Returns: `UIImage` object filled by specific color
    */
    internal class func image(color: UIColor) -> UIImage
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

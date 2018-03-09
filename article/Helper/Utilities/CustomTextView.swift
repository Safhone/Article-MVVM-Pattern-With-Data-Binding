//
//  CustomTextView.swift
//  Core-Data
//
//  Created by Safhone Oung on 1/7/18.
//  Copyright © 2018 Safhone Oung. All rights reserved.
//

import UIKit


class CustomTextView: UITextView, UITextViewDelegate {
    
    private let _placeholderColor: UIColor = UIColor(white: 0.78, alpha: 1)
    private var _placeholderLabel: UILabel!
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            _placeholderLabel.text = placeholder
        }
    }
    
    override var text: String! {
        didSet {
            textViewDidChange(self)
        }
    }
    
    init() {
        super.init(frame: CGRect.zero, textContainer: nil)
        configurePlaceholderLabel()
    }
    
    init(frame: CGRect) {
        super.init(frame: frame, textContainer: nil)
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        configurePlaceholderLabel()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configurePlaceholderLabel()
    }
    
    func configurePlaceholderLabel() {
        self.delegate = self
        
        _placeholderLabel               = UILabel()
        _placeholderLabel.font          = font
        _placeholderLabel.textColor     = _placeholderColor
        _placeholderLabel.text          = placeholder
        _placeholderLabel.numberOfLines = 0
        _placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(_placeholderLabel)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(self.frame.origin.x))-[placeholder]-(\(0))-|", options: [], metrics: nil, views: ["placeholder": _placeholderLabel])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(self.textContainerInset.top))-[placeholder]-(>=\(self.textContainerInset.bottom))-|", options: [], metrics: nil, views: ["placeholder": _placeholderLabel])
        self.addConstraints(constraints)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        _placeholderLabel.isHidden = !textView.text.isEmpty
    }

}

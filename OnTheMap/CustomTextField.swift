//
//  CustomTextField.swift
//  OnTheMap
//
//  Created by Michael Nichols on 7/19/15.
//  Copyright (c) 2015 Michael Nichols. All rights reserved.
//

import Foundation
import UIKit

// custom textfield to use
class CustomTextField: UITextField {
    
    var leftMargin: CGFloat = 10
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var newBound = bounds
        newBound.origin.x += leftMargin
        return newBound
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += leftMargin
        return newBounds
    }
    
}
//
//  UIViewExtension.swift
//  JStore
//
//  Created by Till Chen on 12/24/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit

extension UIView {
    
    var firstResponder: UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for view in self.subviews {
            if let firstResponder = view.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
    
}

extension UIViewController {
    var firstResponder: UIResponder? {
        return view.firstResponder
    }
}

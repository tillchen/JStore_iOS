//
//  NewUserViewController.swift
//  JStore
//
//  Created by Till Chen on 12/29/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit

class NewUserViewController: UIViewController {
    
    let WHATSAPP = 0
    let EMAIL = 1

    @IBOutlet var mNameTextField: UITextField!
    @IBOutlet var mSegmentedControl: UISegmentedControl!
    
    @IBOutlet var mPlusSignLabel: UILabel!
    @IBOutlet var mPrefixTextField: UITextField!
    @IBOutlet var mPhoneTextField: UITextField!
    @IBOutlet var mActivityIndicator: UIActivityIndicatorView!
    
    var mWhatsApp: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onSegmentedControlIndexChanged(_ sender: Any) {
        switch mSegmentedControl.selectedSegmentIndex {
        case WHATSAPP:
            mWhatsApp = true
            mPlusSignLabel.isHidden = false
            mPrefixTextField.isHidden = false
            mPhoneTextField.isHidden = false
        case EMAIL:
            mWhatsApp = false
            mPlusSignLabel.isHidden = true
            mPrefixTextField.isHidden = true
            mPhoneTextField.isHidden = true
        default:
            break
        }
    }
    
    @IBAction func onStartClicked(_ sender: Any) {
    }
    
}

extension NewUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // dismiss the keyboard when pressing return
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { // dismiss the keyboard when touching
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
}

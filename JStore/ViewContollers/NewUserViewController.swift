//
//  NewUserViewController.swift
//  JStore
//
//  Created by Till Chen on 12/29/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase

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
    var mEmail: String = ""
    var mName: String = ""
    var mPrefix: String =  ""
    var mPhone: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mEmail = (Auth.auth().currentUser?.email)!
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
        if !checkTextFields() {
            return
        }
        addUserToDB()
    }
    
    func checkTextFields() -> Bool {
        mName = mNameTextField.text!
        mPrefix = mPrefixTextField.text!
        mPhone = mPhoneTextField.text!
        if mName.isEmpty {
            showAlert("Sorry. Your Full Name can't be empty.")
            return false
        }
        if mWhatsApp && mPrefix.isEmpty {
            showAlert("Sorry. Your Prefix can't be empty.")
            return false
        }
        if mWhatsApp && mPhone.isEmpty {
            showAlert("Sorry. Your Phone can't be empty.")
            return false
        }
        if mWhatsApp && mPrefix.contains(" ") {
            showAlert("Sorry. Please don't contain space for your prefix.")
            return false
        }
        if mWhatsApp && mPhone.contains(" ") {
            showAlert("Sorry. Please don't contain space for your phone.")
            return false
        }
        return true
    }
    
    func addUserToDB() {
        
    }
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
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

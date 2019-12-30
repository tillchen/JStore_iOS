//
//  SecondViewController.swift
//  JStore
//
//  Created by Till Chen on 12/5/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase

class SellViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource{
    
    let CATEGORY_PICKER = 0
    let CONDITION_PICKER = 1
    let mCategories = ["Apparel, Shoes & Watches", "Automotive, Motorcycle & Industrial", "Beauty & Health", "Books & Audible", "Electronics & Computers", "Grocery/Food", "Home, Garden, Pets & DIY", "Automotive, Motorcycle & Industrial", "Sports & Outdoors", "Other"]
    let mConditions = ["New", "Open Box", "Used", "For parts or not working"]
    
    let mCategoryPicker = UIPickerView()
    let mConditionPicker = UIPickerView()
    
    @IBOutlet var mCategoryTextField: UITextField!
    @IBOutlet var mConditionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser!.isAnonymous {
            performSegue(withIdentifier: "AnonymousSell", sender: nil)
        }
        mCategoryPicker.delegate = self
        mCategoryPicker.dataSource = self
        mCategoryPicker.tag = CATEGORY_PICKER
        mConditionPicker.delegate = self
        mConditionPicker.dataSource = self
        mConditionPicker.tag = CONDITION_PICKER
        mCategoryTextField.inputView = mCategoryPicker
        mConditionTextField.inputView = mConditionPicker
        mCategoryTextField.text = mCategories[0] // default
        mConditionTextField.text = mConditions[0] // default
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == CATEGORY_PICKER {
            return mCategories.count
        }
        else { // CONDITION_PICKER
            return mConditions.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == CATEGORY_PICKER {
            return mCategories[row]
        }
        else { // CONDITION_PICKER
            return mConditions[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == CATEGORY_PICKER {
            mCategoryTextField.text = mCategories[row]
        }
        else { // CONDITION_PICKER
            mConditionTextField.text = mConditions[row]
        }
    }

}

extension SellViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // dismiss the keyboard when pressing return
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { // dismiss the keyboard when touching
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
}


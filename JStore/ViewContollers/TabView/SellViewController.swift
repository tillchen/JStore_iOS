//
//  SecondViewController.swift
//  JStore
//
//  Created by Till Chen on 12/5/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class SellViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let TAG = "SellViewController"
    let CATEGORY_PICKER = 0
    let CONDITION_PICKER = 1
    let mCategories = ["Apparel, Shoes & Watches", "Automotive, Motorcycle & Industrial", "Beauty & Health", "Books & Audible", "Electronics & Computers", "Grocery/Food", "Home, Garden, Pets & DIY", "Automotive, Motorcycle & Industrial", "Sports & Outdoors", "Other"]
    let mConditions = ["New", "Open Box", "Used", "For parts or not working"]
    let lightGrayInDarkMode = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 0.2)
    let CASH = "cash"
    let BANK_TRANSFER = "bank_transfer"
    let PAYPAL = "paypal"
    let MEAL_PLAN = "meal_plan"
    
    let mCategoryPicker = UIPickerView()
    let mConditionPicker = UIPickerView()
    
    @IBOutlet var mTitleTextField: UITextField!
    @IBOutlet var mCategoryTextField: UITextField!
    @IBOutlet var mConditionTextField: UITextField!
    @IBOutlet var mDescriptionTextView: UITextView!
    @IBOutlet var mProgressBar: UIProgressView!
    @IBOutlet var mPriceTextField: UITextField!
    @IBOutlet var mCashSwitch: UISwitch!
    @IBOutlet var mBankTransferSwitch: UISwitch!
    @IBOutlet var mPayPalSwitch: UISwitch!
    @IBOutlet var mMealPlanSwitch: UISwitch!
    @IBOutlet var mActivityIndicator: UIActivityIndicatorView!
    
    var mImagePicker: UIImagePickerController!
    var mFileName: String = ""
    var mReadyToFinish: Bool = false
    var mImageUrl: String = ""
    var mFileReference: StorageReference!
    var mTitle: String = ""
    var mDescription: String = ""
    var mPrice: Double?
    var mCategory: String = ""
    var mCondition: String = ""
    var mPaymentOptions: [String] = []
    var mJStoreUser: JStoreUser!
    var db: Firestore!
    var mCriticalError: Bool = false
    var mImageUploaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser!.isAnonymous {
            performSegue(withIdentifier: "AnonymousSell", sender: nil)
            return
        }
        initUI()
        getJStoreUserFromDB()
    }
    
    func initUI() {
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
        var color = lightGrayInDarkMode
        if traitCollection.userInterfaceStyle == .light {
            color = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0)
        }
        mDescriptionTextView.layer.borderColor = color.cgColor
        mDescriptionTextView.layer.borderWidth = 1
        mDescriptionTextView.text = "Description:"
        mDescriptionTextView.textColor = UIColor.lightGray
        mDescriptionTextView.delegate = self
        mProgressBar.isHidden = true
    }
    
    func getJStoreUserFromDB() {
        db = Firestore.firestore()
        let user = Auth.auth().currentUser
        db.collection("users").document((user?.email)!).getDocument() { (document, error) in
            let result = Result {
                try document.flatMap() {
                    try $0.data(as: JStoreUser.self)
                }
            }
            switch result {
            case .success(let JUser):
                if JUser == nil {
                    self.showAlert("Sorry. You are not in our database. Please sign in again.")
                    print("\(self.TAG) mJStoreUser is nil")
                    self.mCriticalError = true
                }
                else {
                    self.mJStoreUser = JUser
                    self.mCriticalError = false
                }
            case .failure(let error):
                print("\(self.TAG) error decoding JStoreUser \(error)")
                self.showAlert("Sorry. A critical error occured. Please try again or restart the app.")
                self.mCriticalError = true
            }
        }
    }
    
    @IBAction func onTakePhotoClicked(_ sender: Any) {
        if mReadyToFinish {
            deleteOldPhoto()
            mReadyToFinish = false
        }
        mImagePicker = UIImagePickerController()
        mImagePicker.delegate = self
        mImagePicker.sourceType = .camera
        present(mImagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        mImagePicker.dismiss(animated: true, completion: nil)
        let image = info[.originalImage] as? UIImage
        guard let compressedImage = (image?.jpegData(compressionQuality: 0.25)) else {
            mReadyToFinish = false
            print("\(TAG) imagePickerController compression failed")
            showAlert("Sorry. Somethign went wrong. Please try again.")
            return
        }
        let storage = Storage.storage()
        mFileName = UUID().uuidString
        mFileReference = storage.reference().child("posts").child(mFileName)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uploadTast = mFileReference.putData(compressedImage, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                self.mReadyToFinish = false
                print("\(self.TAG) imagePickerController upload failed \(String(describing: error))")
                self.showAlert("Sorry. Somethign went wrong. Please try again.")
                return
            }
            self.mFileReference.downloadURL() { (url, error) in
                self.mImageUrl = url?.absoluteString ?? ""
                if self.mImageUrl.isEmpty {
                    self.mReadyToFinish = false
                    self.showAlert("Sorry. Somethign went wrong. Please try again.")
                    return
                }
                else {
                    print("\(self.TAG) photo uploaded: \(String(describing: self.mFileName))")
                    self.mImageUploaded = true
                    self.mReadyToFinish = true
                }
            }
        }
        _ = uploadTast.observe(.progress) { snapshot in
            let percentComplete = Double(snapshot.progress!.completedUnitCount)
              / Double(snapshot.progress!.totalUnitCount)
            self.mProgressBar.isHidden = false
            self.mProgressBar.setProgress(Float(percentComplete), animated: true)
        }
    }
    
    @IBAction func onAddPhotoClicked(_ sender: Any) {
        if mReadyToFinish {
            deleteOldPhoto()
            mReadyToFinish = false
        }
        mImagePicker = UIImagePickerController()
        mImagePicker.delegate = self
        mImagePicker.sourceType = .photoLibrary
        present(mImagePicker, animated: true, completion: nil)
    }
    
    func deleteOldPhoto() {
        mFileReference.delete { error in
            if let error = error {
                print("\(self.TAG) deleteOldPhoto error: \(error)")
            }
        }
    }
    
    @IBAction func onFinishClicked(_ sender: Any) {
        
        if mCriticalError {
            showAlert("Sorry. There are some critical errors. Please restart the app or sign in again.")
            return
        }
        
        if mPriceTextField.text!.isEmpty {
            showAlert("Sorry. Price can't be empty.")
            return
        }
        
        getAndSetData()
        
        if mTitle.isEmpty {
            showAlert("Sorry. Title can't be empty.")
            return
        }
        if mTitle.count > 50 {
            showAlert("Sorry. Title can't be longer than 50 characters.")
            return
        }
        if mDescription == "Description:" {
            showAlert("Sorry. Description can't be empty.")
            return
        }
        if mDescription.count > 300 {
            showAlert("Sorry. Description can't be more than 300 characters.")
            return
        }
        
        if mPrice == nil {
            showAlert("Sorry. Price is invalid.")
            return
        }
        if mPrice == 0 {
            showAlert("Sorry. Price can't be 0.")
            return
        }
        if mPaymentOptions.count == 0 {
            showAlert("Sorry. You must choose at least 1 payment option.")
            return
        }
        if !mImageUploaded {
            showAlert("Sorry. You must upload a photo.")
            return
        }
        if !mReadyToFinish {
            showAlert("Sorry. Some tasks are not finished. Please try again.")
            return
        }
        
        postItem()
    }
    
    func getAndSetData() { // TODO: Check the length of textFields and textView
        mTitle = mTitleTextField.text!
        mDescription = mDescriptionTextView.text!
        mCategory = mCategoryTextField.text!
        mCondition = mConditionTextField.text!
        mPrice = Double(mPriceTextField.text!.replacingOccurrences(of: ",", with: "."))
        mPrice?.round()
        if mCashSwitch.isOn && !mPaymentOptions.contains(CASH) {
            mPaymentOptions.append(CASH)
        }
        if mBankTransferSwitch.isOn && !mPaymentOptions.contains(BANK_TRANSFER) {
            mPaymentOptions.append(BANK_TRANSFER)
        }
        if mPayPalSwitch.isOn && !mPaymentOptions.contains(PAYPAL) {
            mPaymentOptions.append(PAYPAL)
        }
        if mMealPlanSwitch.isOn && !mPaymentOptions.contains(MEAL_PLAN) {
            mPaymentOptions.append(MEAL_PLAN)
        }
    }
    
    func postItem() {
        let post = Post(postId: mFileName, sold: false, ownerId: mJStoreUser.email, ownerName: mJStoreUser.fullName, whatsApp: mJStoreUser.whatsApp, phoneNumber: mJStoreUser.phoneNumber, title: mTitle, category: mCategory, condition: mCondition, description: mDescription, imageUrl: mImageUrl, price: mPrice ?? 0, paymentOptions: mPaymentOptions, creationDate: nil, soldDate: nil)
        mActivityIndicator.startAnimating()
        do {
            try db.collection("posts").document(mFileName).setData(from: post)
            addCreationDate()
        } catch let error {
            print("\(TAG) postItem error: \(error)")
            mActivityIndicator.stopAnimating()
            showAlert("Sorry. Please try again.")
        }
    }
    
    func addCreationDate() {
        print("\(TAG) addCreationDate")
        db.collection("posts").document(mFileName).updateData([
            "creationDate": FieldValue.serverTimestamp()
        ]) { err in
            self.mActivityIndicator.stopAnimating()
            if err != nil {
                self.showAlert("Sorry. Please try again.")
            }
            else {
                self.showAlert("Posted!")
                self.clearFields()
                NotificationCenter.default.post(name: Notification.Name("RefreshBuy"), object: nil)
                NotificationCenter.default.post(name: Notification.Name("RefreshMyPosts"), object: nil)
            }
        }
    }
    
    func clearFields() {
        mTitleTextField.text = ""
        mCategoryTextField.text = mCategories[0]
        mConditionTextField.text = mConditions[0]
        mDescriptionTextView.text = ""
        mProgressBar.isHidden = true
        mPriceTextField.text = ""
        mCashSwitch.isOn = false
        mBankTransferSwitch.isOn = false
        mPayPalSwitch.isOn = false
        mMealPlanSwitch.isOn = false
        mReadyToFinish = false
        mImageUploaded = false
    }

    
    // For the description textView:
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            if traitCollection.userInterfaceStyle == .light {
                textView.textColor = UIColor.black
            }
            else { // dark
                textView.textColor = UIColor.white
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description:"
            textView.textColor = UIColor.lightGray
        }
    }
    
    // For the pickers:
    
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
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
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


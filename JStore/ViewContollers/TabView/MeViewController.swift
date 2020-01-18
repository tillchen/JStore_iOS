//
//  MeViewController.swift
//  JStore
//  Created by Till Chen on 12/5/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class MeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mTableView: UITableView!
    @IBOutlet var mFullNameTextField: UITextField!
    @IBOutlet var mDateLabel: UILabel!
    @IBOutlet var mContactSegmentedControl: UISegmentedControl!
    @IBOutlet var mPlusSignLabel: UILabel!
    @IBOutlet var mPhoneTextField: UITextField!
    @IBOutlet var mLoadActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var mSaveActivityIndicatorView: UIActivityIndicatorView!
    
    let TAG = "MeViewController"
    let mImages = [UIImage(systemName: "doc.circle"), UIImage(systemName: "eurosign.circle"), UIImage(systemName: "bell.circle")]
    let mData = ["Active Posts", "Sold Items", "Notification Settings"]
    let WHATSAPP = 0
    let EMAIL = 1
    
    var mWhatsApp: Bool = true
    var db: Firestore!
    var mJStoreUser: JStoreUser!
    var mName: String = ""
    var mPhone: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser!.isAnonymous {
            performSegue(withIdentifier: "AnonymousMe", sender: nil)
        }
        mTableView.dataSource = self
        mTableView.delegate = self
        db = Firestore.firestore()
        getJStoreUserFromDB()
    }
    
    func getJStoreUserFromDB() {
        mLoadActivityIndicatorView.startAnimating()
        db.collection("users").document((Auth.auth().currentUser?.email)!).getDocument() { (document, error) in
            let result = Result {
                try document.flatMap() {
                    try $0.data(as: JStoreUser.self)
                }
            }
            switch result {
            case .success(let JUser):
                self.mLoadActivityIndicatorView.stopAnimating()
                if JUser == nil {
                    self.showAlert("Sorry. You are not in our database. Please sign in again.")
                    print("\(self.TAG) mJStoreUser is nil")
                }
                else {
                    self.mJStoreUser = JUser
                    self.initUI()
                }
            case .failure(let error):
                self.mLoadActivityIndicatorView.stopAnimating()
                print("\(self.TAG) error decoding JStoreUser \(error)")
                self.showAlert("Sorry. A critical error occured. Please try again or restart the app.")
            }
        }
    }
    
    func initUI() {
        mFullNameTextField.text = mJStoreUser.fullName
        if !mJStoreUser.whatsApp {
            mContactSegmentedControl.selectedSegmentIndex = EMAIL
            mPlusSignLabel.isHidden = true
            mPhoneTextField.isHidden = true
        }
        else {
            mPhoneTextField.text = mJStoreUser.phoneNumber
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        mDateLabel.text = dateFormatter.string(from: mJStoreUser.creationDate!)
    }

    @IBAction func onContactSegmentedControlChanged(_ sender: Any) {
        switch mContactSegmentedControl.selectedSegmentIndex {
         case WHATSAPP:
             mWhatsApp = true
             mPlusSignLabel.isHidden = false
             mPhoneTextField.isHidden = false
         case EMAIL:
             mWhatsApp = false
             mPlusSignLabel.isHidden = true
             mPhoneTextField.isHidden = true
         default:
             break
         }
    }
    
    
    @IBAction func onSaveClicked(_ sender: Any) {
        if !checkTextFields() {
            return
        }
        mFullNameTextField.resignFirstResponder()
        mPhoneTextField.resignFirstResponder()
        updateUserInfo()
    }
    
    func checkTextFields() -> Bool {
        mName = mFullNameTextField.text!
        mPhone = mPhoneTextField.text!
        if mName.isEmpty {
            showAlert("Sorry. Your full name can't be empty.")
            return false
        }
        if mWhatsApp && mPhone.isEmpty {
            showAlert("Sorry. Your phone number can't be empty.")
            return false
        }
        if mWhatsApp && mPhone.contains(" ") {
            showAlert("Sorry. Please don't contain any space for your phone number.")
            return false
        }
        return true
    }
    
    func updateUserInfo() {
        mSaveActivityIndicatorView.startAnimating()
        db.collection("users").document(mJStoreUser.email).updateData([
            "fullName": mName,
            "whatsApp": mWhatsApp,
            "phoneNumber": mPhone
        ]) { err in
            self.mSaveActivityIndicatorView.stopAnimating()
            if err != nil {
                self.showAlert("Sorry. Please try again.")
            }
        }
    }
    
    @IBAction func onSignOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "Signout", sender: nil)
        }
        catch let signOutError as NSError {
            showAlert("Sorry. Something went wrong. Please try again.")
            print(signOutError)
        }
    }
    
    @IBAction func onFeedBackClicked(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mTableView.dequeueReusableCell(withIdentifier: "com.tillchen.jstore.me", for: indexPath) as! MeTableViewCell
        cell.mImageView.image = mImages[indexPath.row]
        cell.mLabel.text = mData[indexPath.row]
        return cell
    }
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

}

extension MeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // dismiss the keyboard when pressing return
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { // dismiss the keyboard when touching
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
}

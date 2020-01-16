//
//  PostDetailsViewController.swift
//  JStore
//
//  Created by Till Chen on 1/8/20.
//  Copyright © 2020 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import FirebaseFirestoreSwift
import MessageUI

class PostDetailsViewController: UIViewController {
    
    let TAG = "PostDetailsViewController"
    let lightGrayInDarkMode = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 0.2)
    
    var db: Firestore!
    var mPost: Post!
    var mJStoreUser: JStoreUser!
    var mUser: User!

    @IBOutlet var mImageView: UIImageView!
    @IBOutlet var mTitleLabel: UILabel!
    @IBOutlet var mPriceLabel: UILabel!
    @IBOutlet var mOwnerNameLabel: UILabel!
    @IBOutlet var mEmailLabel: UILabel!
    @IBOutlet var mCategoryLabel: UILabel!
    @IBOutlet var mConditionLabel: UILabel!
    @IBOutlet var mPostDateLabel: UILabel!
    @IBOutlet var mSoldDateLabel: UILabel!
    @IBOutlet var mDescriptionTextView: UITextView!
    @IBOutlet var mPaymentOptionsLabel: UILabel!
    @IBOutlet var mSendEmailButton: UIButton!
    @IBOutlet var mTextOnWhatsAppButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        
        db = Firestore.firestore()
        
        setData()
        
        getJStoreUserFromDB()
        
    }
    
    @IBAction func onSendEmailClicked(_ sender: Any) {
        sendEmail()
    }
    
    
    @IBAction func onTextOnWhatsAppClicked(_ sender: Any) {
        sendWhatsAppMessage()
    }
    
    
    func initUI() {
        navigationController?.navigationBar.isHidden = true
        var color = lightGrayInDarkMode
        if traitCollection.userInterfaceStyle == .light {
            color = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1.0)
        }
        mDescriptionTextView.layer.borderColor = color.cgColor
        mDescriptionTextView.layer.borderWidth = 1
    }
    
    func setData() {
        mTitleLabel.text = mPost.title
        mImageView.sd_setImage(with: Storage.storage().reference(forURL: mPost.imageUrl))
        mPriceLabel.text = "€ " + String(mPost.price)
        mOwnerNameLabel.text = mPost.ownerName
        mEmailLabel.text = mPost.ownerId
        mCategoryLabel.text = mPost.category
        mConditionLabel.text = mPost.condition
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd HH:mm:ss yyyy"
        mPostDateLabel.text = dateFormatter.string(from: mPost.creationDate!)
        if mPost.sold {
            mSoldDateLabel.text = dateFormatter.string(from: mPost.soldDate!)
        }
        else {
            mSoldDateLabel.text = "Unsold"
        }
        mDescriptionTextView.text = mPost.description
        setPaymentOptions()
    }
    
    func setPaymentOptions() {
        let paymentOptions = mPost.paymentOptions
        var paymentString = ""
        if paymentOptions.contains("cash") {
            paymentString += "Cash    "
        }
        if paymentOptions.contains("bank_transfer") {
            paymentString += "Bank Transfer    "
        }
        if paymentOptions.contains("paypal") {
            paymentString += "PayPal    "
        }
        if paymentOptions.contains("meal_plan") {
            paymentString += "Meal Plan"
        }
        mPaymentOptionsLabel.text = paymentString
    }
    
    func getJStoreUserFromDB() {
        mUser = Auth.auth().currentUser
        db.collection("users").document((mUser?.email)!).getDocument() { (document, error) in
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
                }
                else {
                    self.mJStoreUser = JUser
                }
            case .failure(let error):
                print("\(self.TAG) error decoding JStoreUser \(error)")
                self.showAlert("Sorry. A critical error occured. Please try again or restart the app.")
            }
        }
    }
    
    func sendEmail() {
        var message = "Dear " + mPost.ownerName + ",\n\n Hi! I'm contacting you by clicking on the" +
        " Email button of JStore. I'm interested in the following item:\nhttps://jstore.xyz/posts/" +
        mPost.postId + "\n\nSincerely,\n\n"
        message += (mUser.isAnonymous ? "" : mJStoreUser.fullName)
        let uri = "ms-outlook://compose?to=" + mPost.ownerId + "&subject=" + "[JStore] " + mPost.title + "&body=" + message
        if let url = URL(string: uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            else {
                showAlert("Sorry. You'll need to install the Outlook app.")
            }
        }
    }
    
    func sendWhatsAppMessage() {
        let message = "[JStore] " + mPost.title + "\n\nHi! I'm contacting you by clicking on the " +
        "WhatsApp button of JStore. My name is " + (mUser.isAnonymous ? "" : mJStoreUser.fullName) +
        " and I'm interested in the following item:\nhttps://jstore.xyz/posts/" + mPost.postId
        let uri = "https://wa.me/" + mPost.phoneNumber + "?text=" + message
        if let url = URL(string: uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

}

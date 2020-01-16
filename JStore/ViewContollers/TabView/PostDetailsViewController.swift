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

class PostDetailsViewController: UIViewController {
    
    let TAG = "PostDetailsViewController"
    let lightGrayInDarkMode = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 0.2)
    
    var db: Firestore!
    var mPost: Post!

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
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

}

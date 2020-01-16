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
    
    var mPostID: String!
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
    
    func getPostFromDB() {
        db.collection("posts").document(mPostID).getDocument() { (document, error) in
            let result = Result {
                try document.flatMap() {
                    try $0.data(as: Post.self)
                }
            }
            switch result {
            case .success(let post):
                if post == nil {
                    self.showAlert("Sorry. The post is no longer in the database.")
                    print("\(self.TAG) post is nil")
                }
                else {
                    self.mPost = post
                }
            case .failure(let error):
                print("\(self.TAG) error decoding post \(error)")
                self.showAlert("Sorry. A critical error occured. Please try again or restart the app.")
            }
        }
    }
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }

}

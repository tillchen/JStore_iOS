//
//  MeViewController.swift
//  JStore
//  Created by Till Chen on 12/5/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mTableView: UITableView!
    @IBOutlet var mFullNameTextField: UITextField!
    @IBOutlet var mDateLabel: UILabel!
    @IBOutlet var mContactSegmentedControl: UISegmentedControl!
    @IBOutlet var mPlusSignLabel: UILabel!
    @IBOutlet var mPhoneTextField: UITextField!
    @IBOutlet var mLoadActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet var mSaveActivityIndicatorView: UIActivityIndicatorView!
    
    let mImages = [UIImage(systemName: "doc.circle"), UIImage(systemName: "eurosign.circle"), UIImage(systemName: "bell.circle")]
    let mData = ["Active Posts", "Sold Items", "Notification Settings"]
    let WHATSAPP = 0
    let EMAIL = 1
    
    var mWhatsApp: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser!.isAnonymous {
            performSegue(withIdentifier: "AnonymousMe", sender: nil)
        }
        mTableView.dataSource = self
        mTableView.delegate = self
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

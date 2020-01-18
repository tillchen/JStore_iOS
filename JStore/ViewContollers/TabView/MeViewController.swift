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
    
    let mImages = [UIImage(systemName: "doc.circle"), UIImage(systemName: "eurosign.circle"), UIImage(systemName: "bell.circle")]
    let mData = ["Active Posts", "Sold Items", "Notification Settings"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser!.isAnonymous {
            performSegue(withIdentifier: "AnonymousMe", sender: nil)
        }
        mTableView.dataSource = self
        mTableView.delegate = self
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

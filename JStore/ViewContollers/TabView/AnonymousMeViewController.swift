//
//  AnonymousMeViewController.swift
//  JStore
//
//  Created by Till Chen on 12/29/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase

class AnonymousMeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func onSignOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "AnonymousSignOut", sender: nil)
        }
        catch let signOutError as NSError {
            showAlert("Sorry. Something went wrong. Please try again.")
            print(signOutError)
        }
    }
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }
}

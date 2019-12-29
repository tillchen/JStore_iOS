//
//  MeViewController.swift
//  JStore
//
//  Created by Till Chen on 12/5/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase

class MeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

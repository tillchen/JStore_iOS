//
//  RootNavigationController.swift
//  JStore
//
//  Created by Till Chen on 12/26/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase

class RootNavigationController: UINavigationController {
    
    let TAG = "RootNagivationController"

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser { // Signed in
            if user.isAnonymous { // Anonymous
                print("\(TAG) segue LoggedIn (Anonymous)")
                performSegue(withIdentifier: "LoggedIn", sender: nil)
            }
            else { // Not Anonymous. Check whether in the DB
                let db = Firestore.firestore()
                let docRef = db.collection("users").document(user.email!)
                docRef.getDocument() { (document, error) in
                    if let document = document, document.exists { // Exits, go to the tab controller
                        print("\(self.TAG) segue LoggedIn")
                        self.performSegue(withIdentifier: "LoggedIn", sender: nil)
                    }
                    else { // Registered. But not in DB. Go to the New User Controller
                        print("\(self.TAG) segue LoggedInButNotInDB")
                        self.performSegue(withIdentifier: "LoggedInButNotInDB", sender: nil)
                    }
                }
            }
        }
        else { // not signed in, open LoginViewController
            print("\(TAG) segue Login")
            performSegue(withIdentifier: "Login", sender: nil)
        }
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

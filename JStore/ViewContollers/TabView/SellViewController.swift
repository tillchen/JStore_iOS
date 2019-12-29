//
//  SecondViewController.swift
//  JStore
//
//  Created by Till Chen on 12/5/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase

class SellViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser!.isAnonymous {
            performSegue(withIdentifier: "AnonymousSell", sender: nil)
        }
    }


}


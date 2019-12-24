//
//  LoginViewController.swift
//  JStore
//
//  Created by Till Chen on 12/23/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    let TAG = "LoginViewController"

    @IBOutlet var textView: UITextView!
    
    @IBOutlet var textView2: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHyperLink()

    }

    func setHyperLink() {
        let attributedString1 = NSMutableAttributedString(string: "Made with ❤️ by Tianyao Chen and Taiyr Begeyev")
        attributedString1.addAttribute(.link, value: "mailto:tillchen417@gmail.com", range: NSRange(location: 15, length: 13))
        attributedString1.addAttribute(.link, value: "mailto:taiyrbegeyev@gmail.com", range: NSRange(location: 32, length: 14))
        textView.attributedText = attributedString1
        textView.textColor = .lightGray
        textView.font = UIFont.systemFont(ofSize: 11.0)
        
        let attributedString2 = NSMutableAttributedString(string: "By signing in, you agree to our Terms and Conditions and Privacy Policy")
        attributedString2.addAttribute(.link, value: "https://jstore.xyz/terms_and_conditions", range: NSRange(location: 32, length: 20))
        attributedString2.addAttribute(.link, value: "https://jstore.xyz/privacy_policy", range: NSRange(location: 57, length: 14))
        textView2.attributedText = attributedString2
        textView2.textColor = .lightGray
        textView2.font = UIFont.systemFont(ofSize: 10.0)
    }
    
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // dismiss the keyboard when pressing return
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { // dismiss the keyboard when touching
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
}

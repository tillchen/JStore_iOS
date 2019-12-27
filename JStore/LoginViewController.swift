//
//  LoginViewController.swift
//  JStore
//
//  Created by Till Chen on 12/23/19.
//  Copyright © 2019 Tianyao Chen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    let TAG = "LoginViewController"
    let ADMIN = "tillchen417@gmail.com"
    let USERNAME = "Username"
    let LINK = "Link"
    let EMAIL = "Email"

    @IBOutlet var textView: UITextView!
    @IBOutlet var textView2: UITextView!
    @IBOutlet var textField: UITextField!
    
    @IBOutlet var sendLinkButton: UIButton!
    @IBOutlet var anonymousButton: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var mUsername: String = ""
    var mValidUsername: Bool = false
    var mEmail: String = ""
    var mLink: String! = ""
    var mSignInButton: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHyperLink()
        
        initUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI), name: Notification.Name("LinkReceived"), object: nil)
        
        print("\(TAG) viewDidLoad")
        
    }
    
    func initUI() {
        sendLinkButton.isHidden = false
        textField.isUserInteractionEnabled = true
        mSignInButton = false
        sendLinkButton.setTitle("Send Link", for: .normal)
    }
    
    @objc func updateUI() { // executed when a link is received
        print("\(TAG) updateUI")
        textField.text = UserDefaults.standard.value(forKey: USERNAME) as? String
        if let link = UserDefaults.standard.value(forKey: LINK) as? String {
            mLink = link
            textField.isUserInteractionEnabled = false
            mSignInButton = true
            sendLinkButton.setTitle("Sign In", for: .normal)
            UserDefaults.standard.setValue("", forKey: LINK)
        }
        else {
            print("\(TAG) updateUI link empty")
            showAlert("Something went wrong. Please send another link.")
        }
    }

    @IBAction func onSendLinkClicked(_ sender: Any) {
        
        if mSignInButton {
            onSignInClicked()
        }
        else {
            handleUsername()
        
            if mValidUsername {
                sendEmail()
            }
        }
    }
    
    func onSignInClicked() {
        activityIndicator.startAnimating()
        if let email = UserDefaults.standard.value(forKey: EMAIL) as? String{
            Auth.auth().signIn(withEmail: email, link: mLink) { (user, error) in
                self.activityIndicator.stopAnimating()
                if error != nil {
                    self.showAlert("Sorry. Login failed. Please try again with the new link or reinstall the app.")
                    self.mEmail = email
                    self.sendEmail()
                    return
                }
                if (user?.additionalUserInfo!.isNewUser)! {
                    self.performSegue(withIdentifier: "NewUser", sender: nil)
                }
                else {
                    self.performSegue(withIdentifier: "OldUser", sender: nil)
                }
            }
        }
        else {
            showAlert("Sorry. Something went wrong. Please restart or reinstall the app.")
        }
    }
    
    @IBAction func onAnonymousClicked(_ sender: Any) {
        activityIndicator.startAnimating()
        Auth.auth().signInAnonymously() { (authResult, error) in
            self.activityIndicator.stopAnimating()
            if error != nil {
                self.showAlert("Sorry. Please try again.")
                return
            }
            self.performSegue(withIdentifier: "Anonymous", sender: nil)
        }
    }
    
    func sendEmail() {
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://jstore.xyz")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        actionCodeSettings.setAndroidPackageName("com.tillchen.jstore", installIfNotAvailable: true, minimumVersion: nil)
        
        activityIndicator.startAnimating()
        Auth.auth().sendSignInLink(toEmail: mEmail, actionCodeSettings: actionCodeSettings) { error in
            self.activityIndicator.stopAnimating()
            if error != nil {
                self.showAlert("Some error occurred. Please try again.")
                return
            }
            UserDefaults.standard.set(self.mUsername, forKey: self.USERNAME)
            UserDefaults.standard.set(self.mEmail, forKey: "Email")
            self.showAlert("Link sent! Please check your email.")
        }
    }
    
    func handleUsername() {
        mUsername = textField.text!
        if mUsername.isEmpty {
            showAlert("Your email can't be empty.")
            mValidUsername = false
            return
        }
        if mUsername == ADMIN { // admin mode
            mEmail = mUsername;
            mValidUsername = true
            return
        }
        if mUsername.contains(" ") || mUsername.contains("@") {
            showAlert("Your Jacobs username must contain a dot, no space, and no @, (e.g. ti.chen)")
            mValidUsername = false
        }
        else {
            mEmail = mUsername + "@jacobs-university.de";
            mValidUsername = true
        }
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
    
    func showAlert(_ content: String) {
        let alertController = UIAlertController(title: "JStore", message:
            content, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK!", style: .default))

        self.present(alertController, animated: true, completion: nil)
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

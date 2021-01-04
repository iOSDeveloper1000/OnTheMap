//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Arno Seidel on 15.12.20.
//

import Foundation
import UIKit


// MARK: LoginViewController: UIViewController, UITextViewDelegate

class LoginViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var eMailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpTextView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.signUpTextView.delegate = self
        self.initializeSignUpTextView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.eMailTextfield.text = ""
        self.passwordTextfield.text = ""
    }


    @IBAction func loginButtonPressed(_ sender: Any) {

        self.indicateLoggingIn(true)

        NetworkClient.postUdacitySession(username: eMailTextfield.text ?? "", password: passwordTextfield.text ?? "", completion: self.handleLoginResponse(success:errorMessage:))
    }
    
    
    // MARK: TextView delegate
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return false
    }


    // MARK: Helper and callback methods

    func initializeSignUpTextView() {
        let signUpText = NSMutableAttributedString(string: "Don't have an account? Sign Up.")
        signUpText.addAttribute(.link, value: "https://auth.udacity.com/sign-up", range: NSRange(location: 23, length: 8))
        
        self.signUpTextView.attributedText = signUpText
        self.signUpTextView.textAlignment = .center
        self.signUpTextView.font = UIFont(name: (self.signUpTextView.font?.fontName)!, size: 16)
    }

    func indicateLoggingIn(_ loggingIn: Bool) {
        if loggingIn {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
        eMailTextfield.isEnabled = !loggingIn
        passwordTextfield.isEnabled = !loggingIn
        loginButton.isEnabled = !loggingIn
    }

    func handleLoginResponse(success: Bool, errorMessage: ErrorMessage?) {

        self.indicateLoggingIn(false)
        
        if success {
            self.performSegue(withIdentifier: "loginSuccessful", sender: nil)
        } else {
            FailureHandling.showFailure(onTopOf: self, case: .loginFailed, detailedDescription: errorMessage ?? "")
        }
    }
}

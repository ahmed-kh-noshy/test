//
//  LoginViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 20/11/21.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailContainerView.layer.cornerRadius = 8
        emailContainerView.layer.borderWidth = 1.0
        emailContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
        passwordContainerView.layer.cornerRadius = 8
        passwordContainerView.layer.borderWidth = 1.0
        passwordContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        // Do any additional setup after loading the view.
    }

    @IBAction func loginAction(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else { return }
        
        if email.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your email")
            return
        } else if password.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your password")
            return
        } else if !Utils.isValidEmail(email) {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter valid email")
            return
        }
        
        SVProgressHUD.show()
        Client.shared.login(email: email, password: password) { accessToken in
            SVProgressHUD.dismiss()
            if let accessToken = accessToken {
                AccountController.shared.save(accessToken: accessToken)
                self.navigationController?.popToRootViewController(animated: true)
            } else {
                Utils.showAlertMessage(vc: self, title: "Login Error", message: "Failed to login a customer with this email and password. Please check your credentials and try again.")
            }
        }
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        let signupViewController = storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.navigationController?.pushViewController(signupViewController, animated: true)
    }

    @IBAction func resetPasswordAction(_ sender: Any) {
        let resetPasswordViewController = storyboard?.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        self.navigationController?.pushViewController(resetPasswordViewController, animated: true)
    }
}

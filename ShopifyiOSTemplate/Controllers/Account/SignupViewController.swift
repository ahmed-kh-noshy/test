//
//  SignupViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 20/11/21.
//

import UIKit
import SVProgressHUD

class SignupViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameContainerView: UIView!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordContainerView: UIView!
    @IBOutlet weak var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        firstNameContainerView.layer.cornerRadius = 8
        firstNameContainerView.layer.borderWidth = 1.0
        firstNameContainerView.layer.borderColor = UIColor.lightGray.cgColor

        lastNameContainerView.layer.cornerRadius = 8
        lastNameContainerView.layer.borderWidth = 1.0
        lastNameContainerView.layer.borderColor = UIColor.lightGray.cgColor

        emailContainerView.layer.cornerRadius = 8
        emailContainerView.layer.borderWidth = 1.0
        emailContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
        passwordContainerView.layer.cornerRadius = 8
        passwordContainerView.layer.borderWidth = 1.0
        passwordContainerView.layer.borderColor = UIColor.lightGray.cgColor

        confirmPasswordContainerView.layer.cornerRadius = 8
        confirmPasswordContainerView.layer.borderWidth = 1.0
        confirmPasswordContainerView.layer.borderColor = UIColor.lightGray.cgColor

        signUpButton.layer.cornerRadius = signUpButton.frame.height / 2

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text else { return }
        
        if firstName.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your first name")
            return
        } else if lastName.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your last name")
            return
        } else if email.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your email")
            return
        } else if password.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your password")
            return
        } else if confirmPassword.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your confirm password")
            return
        } else if password != confirmPassword {
            Utils.showAlertMessage(vc: self, title: "", message: "Your password and confirm password are not same")
            return
        } else if !Utils.isValidEmail(email) {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter valid email")
            return
        }
        
        SVProgressHUD.show()
        Client.shared.signUp(email: email, password: password, firstName: firstName, lastName: lastName) { customerUserErrors in
            if customerUserErrors.isEmpty {
                Client.shared.login(email: email, password: password) { accessToken in
                    SVProgressHUD.dismiss()
                    if let accessToken = accessToken {
                        AccountController.shared.save(accessToken: accessToken)
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            } else {
                SVProgressHUD.dismiss()
                if let error = customerUserErrors.first {
                    Utils.showAlertMessage(vc: self, title: "SignUp Error", message: error.message)
                }
            }
        }
        
        SVProgressHUD.show()
    }

}

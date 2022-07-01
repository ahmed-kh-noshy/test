//
//  ResetPasswordViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 22/11/21.
//

import UIKit
import SVProgressHUD

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        emailContainerView.layer.cornerRadius = 8
        emailContainerView.layer.borderWidth = 1.0
        emailContainerView.layer.borderColor = UIColor.lightGray.cgColor

        submitButton.layer.cornerRadius = submitButton.frame.height / 2

        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction(_ sender: Any) {
        guard let email = emailTextField.text else { return }
        
        if email.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your email")
            return
        } else if !Utils.isValidEmail(email) {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter valid email")
            return
        }
        
        SVProgressHUD.show()
        Client.shared.resetUserPassword(email: email) { resetUserError in
            SVProgressHUD.dismiss()
            if let error = resetUserError, let customerRecover = error.fields["customerRecover"] as? [String: Any], let customerUserErrors = customerRecover["customerUserErrors"] as? [[String: Any]], let messages = customerUserErrors.first {
                Utils.showAlertMessage(vc: self, title: "Error", message: messages["message"] as? String ?? "")
            } else if let error = resetUserError, let customerRecover = error.fields["customerRecover"] as? [String: Any], let customerUserErrors = customerRecover["customerUserErrors"] as? [[String: Any]], customerUserErrors.isEmpty {
                Utils.showAlertMessage(vc: self, title: "", message: "Link sent successfully") {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                Utils.showAlertMessage(vc: self, title: "", message: "Something wrong!")
            }
        }
    }

}

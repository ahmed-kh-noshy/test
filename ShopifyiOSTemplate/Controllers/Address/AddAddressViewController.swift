//
//  AddAddressViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 25/11/21.
//

import UIKit
import SVProgressHUD

protocol AddAddressViewControllerDelegate: AnyObject {
    func didCreateorUpdateAddress()
}

class AddAddressViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var address1TextField: UITextField!
    @IBOutlet weak var address2TextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    weak var delegate: AddAddressViewControllerDelegate?
    var address: SavedAddressViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Address"
        
        if let address = address {
            firstNameTextField.text = address.firstName
            lastNameTextField.text = address.lastName
            phoneTextField.text = address.phone
            address1TextField.text = address.address1
            address2TextField.text = address.address2
            cityTextField.text = address.city
            provinceTextField.text = address.province
            countryTextField.text = address.country
            zipCodeTextField.text = address.zip
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        guard let address1 = address1TextField.text, let address2 = address2TextField.text, let city = cityTextField.text, let country = countryTextField.text, let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, let phone = phoneTextField.text, let province = provinceTextField.text, let zip = zipCodeTextField.text else { return }

        if lastName.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your last name")
            return
        } else if address1.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your address")
            return
        } else if city.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your city")
            return
        } else if province.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your province")
            return
        } else if country.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your country")
            return
        } else if zip.isEmpty {
            Utils.showAlertMessage(vc: self, title: "", message: "Please enter your zip code")
            return
        }
        
        SVProgressHUD.show()
        
        if let address = address {
            Client.shared.customerAddressUpdate(address: address, address1: address1, address2: address2, city: city, country: country, firstName: firstName, lastName: lastName, phone: phone, province: province, zip: zip, accessToken: AccountController.shared.accessToken ?? "") { customerUserErrors in
                SVProgressHUD.dismiss()
                if customerUserErrors.isEmpty {
                    self.delegate?.didCreateorUpdateAddress()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    SVProgressHUD.dismiss()
                    if let error = customerUserErrors.first {
                        Utils.showAlertMessage(vc: self, title: "Add Address Error", message: error.message)
                    }
                }
            }
        } else {
            Client.shared.customerAddressCreate(address1: address1, address2: address2, city: city, country: country, firstName: firstName, lastName: lastName, phone: phone, province: province, zip: zip, accessToken: AccountController.shared.accessToken ?? "") { customerUserErrors in
                SVProgressHUD.dismiss()
                if customerUserErrors.isEmpty {
                    self.delegate?.didCreateorUpdateAddress()
                    self.navigationController?.popViewController(animated: true)
                } else {
                    SVProgressHUD.dismiss()
                    if let error = customerUserErrors.first {
                        Utils.showAlertMessage(vc: self, title: "Add Address Error", message: error.message)
                    }
                }
            }
        }
    }
    
}

//
//  ViewAddressTableViewCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 26/11/21.
//

import UIKit

protocol ViewAddressTableViewCellDelegate: AnyObject {
    func didTapSetDefaultAddress(address: SavedAddressViewModel?)
    func didTapEditAddress(address: SavedAddressViewModel?)
    func didTapDeleteAddress(address: SavedAddressViewModel?)
}

class ViewAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var address1Label: UILabel!
    @IBOutlet weak var address2Label: UILabel!
    @IBOutlet weak var address3Label: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var defaultButton: UIButton!
    
    weak var delegate: ViewAddressTableViewCellDelegate?
    var model: SavedAddressViewModel?
    var defaultAddressID: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI(model: SavedAddressViewModel?, defaultAddressID: String?) {
        self.model = model
        self.defaultAddressID = defaultAddressID
        
        var name = ""
        let address1 = model?.address1 ?? ""
        let address2 = model?.address2 ?? ""
        var address3 = ""
        let country = model?.country ?? ""
        let phone = model?.phone ?? ""

        if let firstName = model?.firstName, !firstName.isEmpty {
            name = firstName
        }
        
        if let lastName = model?.lastName, !lastName.isEmpty {
            name = name.isEmpty ? lastName : (name + " " + lastName)
        }
        
        if let zip = model?.zip, !zip.isEmpty {
            address3 = zip
        }
        
        if let city = model?.city, !city.isEmpty {
            address3 = address3.isEmpty ? city : (address3 + " " + city)
        }
        
        if let province = model?.province, !province.isEmpty {
            address3 = address3.isEmpty ? province : (address3 + " " + province)
        }
        
        nameLabel.text = name
        address1Label.text = address1
        address2Label.text = address2
        address3Label.text = address3
        countryLabel.text = country
        phoneLabel.text = phone
        
        nameLabel.isHidden = name.isEmpty
        address1Label.isHidden = address1.isEmpty
        address2Label.isHidden = address2.isEmpty
        address3Label.isHidden = address3.isEmpty
        countryLabel.isHidden = country.isEmpty
        phoneLabel.isHidden = phone.isEmpty
        
        if model?.id.rawValue == defaultAddressID {
            defaultButton.setTitle("Default Address", for: .normal)
        } else {
            defaultButton.setTitle("Make Default", for: .normal)
        }
    }
    
    @IBAction func setDefaultAction(_ sender: Any) {
        if model?.id.rawValue != defaultAddressID {
            delegate?.didTapSetDefaultAddress(address: model)
        }
    }
    
    @IBAction func editAddressAction(_ sender: Any) {
        delegate?.didTapEditAddress(address: model)
    }
    
    @IBAction func deleteAddressAction(_ sender: Any) {
        delegate?.didTapDeleteAddress(address: model)
    }
    
}

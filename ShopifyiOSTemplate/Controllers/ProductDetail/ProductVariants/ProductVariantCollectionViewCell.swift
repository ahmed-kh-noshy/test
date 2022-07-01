//
//  ProductVariantCollectionViewCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 17/11/21.
//

import UIKit

class ProductVariantCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var optionName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.black.cgColor
    }

}

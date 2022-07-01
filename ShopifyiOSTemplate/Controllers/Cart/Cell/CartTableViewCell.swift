//
//  CartTableViewCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 18/11/21.
//

import UIKit

protocol CartTableViewCellDelegate: AnyObject {
    func cartUpdated()
    func cartVariantMaxReacher(availableQuantity: Int)
}

class CartTableViewCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var variantTitleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    var model: CartModel?
    weak var delegate: CartTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        productImageView.layer.masksToBounds = true
        productImageView.layer.cornerRadius = 8
        deleteButton.setTitle("", for: .normal)
    }

    func setupUI(model: CartModel) {
        self.model = model
        
        productTitleLabel.text = model.productTitle
        variantTitleLabel.text = model.productVariantTitle
        priceLabel.attributedText = Utils.formattedPriceString(price: model.productPrice, compareAtPrice: model.compareAtPrice)
        quantityLabel.text = "\(model.selectedQuantity)"
        
        if model.productImageUrls.count > 0 {
            productImageView.contentMode = .scaleAspectFill
            if let url = URL(string: model.productImageUrls[0]) {
                productImageView.setImageFrom(url)
            }
        } else {
            productImageView.backgroundColor = .lightGray.withAlphaComponent(0.1)
            productImageView.contentMode = .center
            productImageView.image = UIImage(named: "no-image")!
        }
    }
    
    @IBAction func minusAction(_ sender: Any) {
        guard let model = model else { return }
        guard model.selectedQuantity > 1 else { return }
        CartManager.shared.updateCartItemCount(item: model, count: model.selectedQuantity - 1)
        delegate?.cartUpdated()
    }
    
    @IBAction func plusAction(_ sender: Any) {
        guard let model = model else { return }
        if (model.selectedQuantity + 1) <= model.availableQuantity {
            CartManager.shared.updateCartItemCount(item: model, count: model.selectedQuantity + 1)
            delegate?.cartUpdated()
        } else {
            delegate?.cartVariantMaxReacher(availableQuantity: model.availableQuantity)
        }
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        guard let model = model else { return }
        CartManager.shared.deleteCartItem(item: model)
        delegate?.cartUpdated()
    }
}

//
//  MyOrderTableViewCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 24/11/21.
//

import UIKit

class MyOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var orderIDLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI(model: OrderViewModel?) {
        orderIDLabel.text = "Order NO: \(model?.number ?? 0)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, yyyy"
        dateLabel.text = dateFormatter.string(from: model?.processedAt ?? Date())
        priceLabel.text = Currency.stringFrom(model?.totalPrice ?? 0.0)
    }
}

//
//  ProductVariantsTableViewCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 17/11/21.
//

import UIKit
import MobileBuySDK

protocol ProductVariantsTableViewCellDelegate: AnyObject {
    func updateSelectedOption(selectedIndex: Int?, selectedOption: String?)
}

class ProductVariantsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var optionNameLabel: UILabel!
    var options: Storefront.ProductOption?
    var selectedOption: String?
    var selectedIndex: Int?
    weak var delegate: ProductVariantsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupUI(options: Storefront.ProductOption, selectedIndex: Int?, selectedOption: String?) {
        self.options = options
        self.optionNameLabel.text = options.name
        self.selectedOption = selectedOption
        self.selectedIndex = selectedIndex
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ProductVariantCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProductVariantCollectionViewCell")
        collectionView.reloadData()
    }
}

extension ProductVariantsTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options?.values.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductVariantCollectionViewCell", for: indexPath) as! ProductVariantCollectionViewCell
        let option = options?.values[indexPath.row]
        cell.optionName.text = option
        cell.containerView.backgroundColor = option == selectedOption ? .red : .white
        cell.optionName.textColor = option == selectedOption ? .white : .black
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.updateSelectedOption(selectedIndex: selectedIndex,
                                       selectedOption: options?.values[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductVariantCollectionViewCell", for: indexPath) as! ProductVariantCollectionViewCell
        let label = UILabel(frame: CGRect.zero)
        label.text = options?.values[indexPath.row]
        label.font = cell.optionName.font
        label.sizeToFit()
        let width = (label.frame.width + 10) > 70 ? (label.frame.width + 10) : 70
        return CGSize(width: width, height: 32)
    }
}

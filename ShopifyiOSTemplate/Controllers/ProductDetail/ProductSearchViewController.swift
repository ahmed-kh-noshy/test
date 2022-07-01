//
//  ProductSearchViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 22/11/21.
//

import UIKit

class ProductSearchViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    var products: PageableArray<ProductViewModel>?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Find Products"
        
        searchTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)

        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ProductCellCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProductCellCollectionViewCell")

        searchTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        Client.shared.fetchProducts(searchTerm: textField.text!, after: nil) { products in
            self.products = products
            self.collectionView.reloadData()
        }
    }
}

extension ProductSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellCollectionViewCell", for: indexPath) as! ProductCellCollectionViewCell
        let item = products?.items[indexPath.row]
        cell.setupUI(model: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productDetailViewController = storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
        let product = products?.items[indexPath.row]
        productDetailViewController.productID = product?.id ?? ""
        self.navigationController?.pushViewController(productDetailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
}

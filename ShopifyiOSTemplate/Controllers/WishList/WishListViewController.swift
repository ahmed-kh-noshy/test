//
//  WishListViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 23/11/21.
//

import UIKit

struct WishListModel {
    var productID: String
    var productPrice: String
    var productTitle: String
    var productImageUrls: [String]
}

class WishListViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyStateView: UIView!
    var emptyStateVC: EmptyStateViewController?
    var products: [WishListModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Favorite Products"
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ProductCellCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProductCellCollectionViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        products = CartManager.shared.retrieveWishListData()
        
        if products.isEmpty {
            emptyStateView.isHidden = false
            emptyStateVC?.emptyTitle = "Your Favorite Products is Empty"
            emptyStateVC?.emptyMessage = "Looks like you haven't added anything to Favorite Products yet"
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emptyStateSegue", let destinationVC = segue.destination as? EmptyStateViewController {
            self.emptyStateVC = destinationVC
        }
    }
}

extension WishListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellCollectionViewCell", for: indexPath) as! ProductCellCollectionViewCell
        let item = products[indexPath.row]
        cell.setupUI(model: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productDetailViewController = storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
        let product = products[indexPath.row]
        productDetailViewController.productID = product.productID
        self.navigationController?.pushViewController(productDetailViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
}

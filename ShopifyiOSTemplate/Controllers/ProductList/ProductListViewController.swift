//
//  ProductListViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 15/11/21.
//

import UIKit

class ProductListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var collectionID: String = ""
    var listTitle: String? = ""
    @IBOutlet weak var emptyStateView: UIView!
    var emptyStateVC: EmptyStateViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = listTitle
        setupUI(collectionID: collectionID)
        // Do any additional setup after loading the view.
    }
    
    func setupUI(collectionID: String) {
        self.collectionID = collectionID
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ProductCellCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProductCellCollectionViewCell")
        
        let isProductFetched = ShopifyCategoryProductManager.shared.isProductFetched[collectionID] ?? false
        
        if !isProductFetched {
            ShopifyCategoryProductManager.shared.fetchProducts(collectionID: collectionID, completion: { [weak self] in
                self?.collectionView.reloadData()
                let products = ShopifyCategoryProductManager.shared.products[collectionID]?.items
                if (products?.isEmpty ?? (products == nil)) {
                    self?.emptyStateView.isHidden = false
                    self?.emptyStateVC?.emptyTitle = "No Products Found"
                    self?.emptyStateVC?.emptyMessage = "There are no products found under this collection"
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emptyStateSegue", let destinationVC = segue.destination as? EmptyStateViewController {
            self.emptyStateVC = destinationVC
        }
    }
}

extension ProductListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let flowayout = collectionViewLayout as? UICollectionViewFlowLayout
        let space: CGFloat = (flowayout?.minimumInteritemSpacing ?? 0.0) + (flowayout?.sectionInset.left ?? 0.0) + (flowayout?.sectionInset.right ?? 0.0)
        let size:CGFloat = (collectionView.frame.size.width - space) / 2.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShopifyCategoryProductManager.shared.products[collectionID]?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellCollectionViewCell", for: indexPath) as! ProductCellCollectionViewCell
        let item = ShopifyCategoryProductManager.shared.products[collectionID]?.items[indexPath.row]
        cell.setupUI(model: item, showWishList: true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productDetailViewController = storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
        let product = ShopifyCategoryProductManager.shared.products[collectionID]?.items[indexPath.row]
        productDetailViewController.productID = product?.id ?? ""
        self.navigationController?.pushViewController(productDetailViewController, animated: true)
    }
}

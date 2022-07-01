//
//  HorizontalProductTableViewCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 13/11/21.
//

import UIKit

class ShopifyCategoryProductManager {
    
    var isAllCategoryFetched: Bool = false
    var isCategoryFetching: Bool = false
    var isProductFetched: [String: Bool] = [:]
    var products: [String: PageableArray<ProductViewModel>] = [:]

    fileprivate var collections: PageableArray<CollectionViewModel>?

    static let shared = ShopifyCategoryProductManager()
    
    private init() {}
    
    func fetchProducts(collectionID: String, completion: @escaping () -> Void) {
        
        Client.shared.fetchProducts(in: collectionID) { products in
            if let products = products {
                self.products[collectionID] = products
            }
            completion()
        }
    }
    
    func fetchNextCategory(completion: @escaping () -> Void) {
        if let collections = self.collections,
            let lastCollection = collections.items.last {
            self.isCategoryFetching = true
            Client.shared.fetchCollections(after: lastCollection.cursor) { collections in
                if let collections = collections {
                    self.collections?.appendPage(from: collections)
                    if collections.items.isEmpty {
                        self.isAllCategoryFetched = true
                    }
                }
                self.isCategoryFetching = false
                completion()
            }
        }
    }
}

protocol HorizontalProductTableViewCellDelegate: AnyObject {
    func didSelectAll(collectionID: String, listTitle: String?)
    func didSelectProduct(product: ProductViewModel?)
}

class HorizontalProductTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    var config: HorizontalProductsConfig?
    weak var delegate: HorizontalProductTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(config: HorizontalProductsConfig?) {
        self.config = config
        
        titleLabel.text = config?.title
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "ProductCellCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ProductCellCollectionViewCell")
        
        let isProductFetched = ShopifyCategoryProductManager.shared.isProductFetched[config?.collectionID ?? ""] ?? false
        
        if !isProductFetched {
            ShopifyCategoryProductManager.shared.fetchProducts(collectionID: config?.collectionID ?? "", completion: { [weak self] in
                self?.collectionView.reloadData()
            })
        }
    }
    
    @IBAction func seeAllAction(_ sender: Any) {
        delegate?.didSelectAll(collectionID: config?.collectionID ?? "", listTitle: config?.title)
    }
}

extension HorizontalProductTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShopifyCategoryProductManager.shared.products[config?.collectionID ?? ""]?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCellCollectionViewCell", for: indexPath) as! ProductCellCollectionViewCell
        let item = ShopifyCategoryProductManager.shared.products[config?.collectionID ?? ""]?.items[indexPath.row]
        cell.setupUI(model: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = ShopifyCategoryProductManager.shared.products[config?.collectionID ?? ""]?.items[indexPath.row]
        delegate?.didSelectProduct(product: item)
    }
}

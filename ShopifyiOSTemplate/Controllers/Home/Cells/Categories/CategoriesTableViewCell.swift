//
//  CategoriesTableViewCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 14/11/21.
//

import UIKit

class ShopifyCategoryManager {
    
    var isCategoryFetched: Bool = false
    var isAllCategoryFetched: Bool = false
    var isCategoryFetching: Bool = false

    fileprivate var collections: PageableArray<CollectionViewModel>?

    static let shared = ShopifyCategoryManager()
    
    private init() {}
    
    func fetchCategory(completion: @escaping () -> Void) {
        
        Client.shared.fetchCollections() { collections in
            if let collections = collections {
                self.collections = collections
            }
            self.isCategoryFetched = true
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

protocol CategoriesTableViewCellDelegate: AnyObject {
    func didSelectCategory(collectionID: String, listTitle: String?)
}

class CategoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: HorizontalProductTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: "CategoriesCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "CategoriesCollectionViewCell")
        
        if !ShopifyCategoryManager.shared.isCategoryFetched {
            ShopifyCategoryManager.shared.fetchCategory { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
}

extension CategoriesTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShopifyCategoryManager.shared.collections?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCollectionViewCell", for: indexPath) as! CategoriesCollectionViewCell
        let item = ShopifyCategoryManager.shared.collections?.items[indexPath.row]
        cell.setupUI(model: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 99)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let items = ShopifyCategoryManager.shared.collections?.items, (indexPath.row == items.count - 1) {
            if !ShopifyCategoryManager.shared.isAllCategoryFetched, !ShopifyCategoryManager.shared.isCategoryFetching {
                ShopifyCategoryManager.shared.fetchNextCategory { [weak self] in
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let collection = ShopifyCategoryManager.shared.collections?.items[indexPath.row] {
            delegate?.didSelectAll(collectionID: collection.id, listTitle: collection.title)
        }
    }
}

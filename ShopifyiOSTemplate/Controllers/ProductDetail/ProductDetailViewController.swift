//
//  ProductDetailViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 15/11/21.
//

import UIKit
import FSPagerView
import MobileBuySDK
import WebKit
import CoreData
import SVProgressHUD

enum VariantAvailability: String {
    case AddedToCart
    case AddToCart
    case OutOfStock
}

class ProductDetailViewController: UIViewController {

    fileprivate var productImageUrls: [String] = []
    private var product: ProductViewModel?
    var productID = ""

    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    @IBOutlet weak var pageControl: FSPageControl! {
        didSet {
            self.pageControl.numberOfPages = self.productImageUrls.count
            self.pageControl.contentHorizontalAlignment = .center
            self.pageControl.contentInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            self.pageControl.hidesForSinglePage = true
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var optionsTableView: UITableView!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var optionsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionWebView: WKWebView!
    @IBOutlet weak var descriptionWebViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wishListContainerView: UIView!
    @IBOutlet weak var wishListIcon: UIImageView!
    @IBOutlet weak var selectVariantLabel: UILabel!
    
    var selectedOptions: [String?] = []
    
    var variantAvailability: VariantAvailability = .AddToCart {
        didSet {
            if let addToCartButton = addToCartButton {
                switch variantAvailability {
                case .AddedToCart:
                    addToCartButton.setTitle("View in cart", for: .normal)
                case .AddToCart:
                    addToCartButton.setTitle("Add to cart", for: .normal)
                case .OutOfStock:
                    addToCartButton.setTitle("Out of stock", for: .normal)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        wishListContainerView.isHidden = false
        wishListContainerView.layer.cornerRadius = wishListContainerView.frame.width / 2
        wishListContainerView.layer.masksToBounds = true

        scrollView.isHidden = true
        if !productID.isEmpty {
            SVProgressHUD.show()

            Client.shared.fetchProduct(id: productID) { model in
                SVProgressHUD.dismiss()

                self.scrollView.isHidden = false
                self.product = model
                self.updateProductUI()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func updateProductUI() {
        if let product = product {
            productImageUrls = product.images.items.map {
                $0.url.absoluteString
            }
            pageControl.numberOfPages = productImageUrls.count

            titleLabel.text = product.title
            
            var selectedVariantTitle = ""
            
            pageControl.isHidden = (productImageUrls.count <= 1)
            
            if !pageControl.isHidden {
                pageControl.currentPage = 0
            }
            
            if product.options.count == 1 {
                selectVariantLabel.isHidden = true
                optionsTableView.isHidden = true
                selectedOptions.insert(product.options[0].values.first, at: 0)
                selectedVariantTitle = selectedOptions.compactMap({$0}).first ?? ""
            } else {
                for i in 0..<product.options.count {
                    selectedOptions.insert(product.options[i].values.first, at: i)
                }
                selectedVariantTitle = selectedOptions.compactMap({$0}).joined(separator: " / ")
            }
            
            priceLabel.attributedText = product.variants.items.first?.formattedPriceString()
            
            if let availableForSale = product.variants.items.first?.availableForSale, !availableForSale {
                variantAvailability = .OutOfStock
            } else if CartManager.shared.isProductInCart(product: product, selectedVariantTitle: selectedVariantTitle) {
                variantAvailability = .AddedToCart
            } else {
                variantAvailability = .AddToCart
            }
            
            setupDescriptionWebView()
            
            pagerView.reloadData()
            optionsTableView.reloadData()
            
            if CartManager.shared.isProductInWishList(product: product) {
                wishListIcon.image = UIImage(systemName: "heart.fill")
            } else {
                wishListIcon.image = UIImage(systemName: "heart")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let product = product {
            var selectedVariantTitle = ""

            if product.options.count == 1 {
                selectedVariantTitle = selectedOptions.compactMap({$0}).first ?? ""
            } else {
                selectedVariantTitle = selectedOptions.compactMap({$0}).joined(separator: " / ")
            }
            
            if let selectedVariant = product.variants.items.filter({ $0.title == selectedVariantTitle }).first {
                if !selectedVariant.availableForSale {
                    variantAvailability = .OutOfStock
                } else if CartManager.shared.isProductInCart(product: product, selectedVariantTitle: selectedVariantTitle) {
                    variantAvailability = .AddedToCart
                } else {
                    variantAvailability = .AddToCart
                }
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.optionsTableViewHeightConstraint?.constant = self.optionsTableView.intrinsicContentSize.height
    }
    
    func setupTableView() {
        optionsTableView.delegate = self
        optionsTableView.dataSource = self
        optionsTableView.register(UINib(nibName: "ProductVariantsTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "ProductVariantsTableViewCell")
    }
    
    func setupDescriptionWebView() {
        descriptionWebView.navigationDelegate = self
        let htmlString = product?.summary ?? ""
        let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"><style>img{width:auto;height:auto;max-width:100%;}</style></HEAD><BODY>"
        let htmlEnd = "</BODY></HTML>"
        let htmlContent = "\(htmlStart)\(htmlString)\(htmlEnd)"
        descriptionWebView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    @IBAction func addToCartAction(_ sender: Any) {
        if variantAvailability == .AddedToCart {
            let productListViewController = storyboard?.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
            self.navigationController?.pushViewController(productListViewController, animated: true)
        } else {
            if let product = product {
                var selectedVariantTitle = ""
                if product.options.count == 1 {
                    selectedVariantTitle = selectedOptions.compactMap({$0}).first ?? ""
                } else {
                    selectedVariantTitle = selectedOptions.compactMap({$0}).joined(separator: " / ")
                }
                if let selectedVariant = product.variants.items.filter({ $0.title == selectedVariantTitle }).first {
                    if selectedVariant.availableForSale && !CartManager.shared.isProductInCart(product: product, selectedVariantTitle: selectedVariantTitle) {
                        variantAvailability = .AddedToCart

                        CartManager.shared.insertCartItem(product: product,
                                                          selectedVariantTitle: selectedVariantTitle,
                                                          selectedVariantAvailableQuantity: selectedVariant.availableQuantity,
                                                          selectedVariantID: selectedVariant.id,
                                                          productImageUrls: productImageUrls,
                                                          productPrice: selectedVariant.price,
                                                          compareAtPrice: selectedVariant.compareAtPrice ?? selectedVariant.price)
                    }
                }
            }
        }
    }
    
    @IBAction func wishListAction(_ sender: Any) {
        if let product = product {
            if CartManager.shared.isProductInWishList(product: product) {
                CartManager.shared.deleteWishListItem(product: product)
                wishListIcon.image = UIImage(systemName: "heart")
            } else {
                CartManager.shared.insertWishListItem(product: product)
                wishListIcon.image = UIImage(systemName: "heart.fill")
            }
        }
    }
}

extension ProductDetailViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    // MARK:- FSPagerViewDataSource
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return productImageUrls.count == 0 ? 1 : productImageUrls.count
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if productImageUrls.count > 0 {
            cell.imageView?.contentMode = .scaleAspectFill
            if let url = URL(string: productImageUrls[index]) {
                cell.imageView?.setImageFrom(url)
            }
        } else {
            cell.imageView?.backgroundColor = .lightGray.withAlphaComponent(0.1)
            cell.imageView?.contentMode = .center
            cell.imageView?.image = UIImage(named: "no-image")!
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        pagerView.deselectItem(at: index, animated: true)
    }
    
    // MARK:- FSPagerViewDelegate
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
    }
}

extension ProductDetailViewController: UITableViewDelegate, UITableViewDataSource {
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product?.options.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductVariantsTableViewCell", for: indexPath) as! ProductVariantsTableViewCell
        cell.delegate = self
        if let options = product?.options {
            cell.setupUI(options: options[indexPath.row], selectedIndex: indexPath.row, selectedOption: selectedOptions[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension ProductDetailViewController: ProductVariantsTableViewCellDelegate {
    
    func updateSelectedOption(selectedIndex: Int?, selectedOption: String?) {
        if let selectedIndex = selectedIndex {
            selectedOptions[selectedIndex] = selectedOption
            let selectedVariantTitle = selectedOptions.compactMap({$0}).joined(separator: " / ")
            if let selectedVariant = product?.variants.items.filter({ $0.title == selectedVariantTitle }).first {
                priceLabel.attributedText = selectedVariant.formattedPriceString()
            }
            optionsTableView.reloadData()
            if let product = product {
                let selectedVariantTitle = selectedOptions.compactMap({$0}).joined(separator: " / ")
                if let selectedVariant = product.variants.items.filter({ $0.title == selectedVariantTitle }).first {
                    if !selectedVariant.availableForSale {
                        variantAvailability = .OutOfStock
                    } else if CartManager.shared.isProductInCart(product: product, selectedVariantTitle: selectedVariantTitle) {
                        variantAvailability = .AddedToCart
                    } else {
                        variantAvailability = .AddToCart
                    }
                }
            }
        }
    }
}

extension ProductDetailViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
                    self.descriptionWebViewHeightConstraint.constant = height as? CGFloat ?? 100
                })
            }
        })
    }
}

final class DynamicSizeTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}

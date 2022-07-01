//
//  ViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 04/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var config: Config?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        self.navigationItem.leftBarButtonItems = [self.barButtonItem(image: UIImage(named: "hamburger")!, tag: 0, action: #selector(self.menuButtonAction(_:)))]
        
        self.navigationItem.rightBarButtonItem = self.barButtonItem(image: UIImage(named: "cart")!, tag: 0, action: #selector(self.cartButtonAction(_:)))
        
        if let localData = self.readLocalFile(forName: "config") {
            self.parse(jsonData: localData)
        }
    }

    private func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func parse(jsonData: Data) {
        do {
            let decodedData = try JSONDecoder().decode(Config.self,
                                                       from: jsonData)
            
            self.config = decodedData
            self.tableView.reloadData()
        } catch {
            print(error)
            print("decode error")
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "SearchTableViewCell")
        tableView.register(UINib(nibName: "PagerViewTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "PagerViewTableViewCell")
        tableView.register(UINib(nibName: "SingleImageBannerCell", bundle: nil),
                           forCellReuseIdentifier: "SingleImageBannerCell")
        tableView.register(UINib(nibName: "HorizontalProductTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "HorizontalProductTableViewCell")
        tableView.register(UINib(nibName: "CategoriesTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "CategoriesTableViewCell")
    }

    @objc func menuButtonAction(_ button: UIButton){
        sideMenuController?.revealMenu()
    }
    
    @objc func cartButtonAction(_ button: UIButton){
        let productListViewController = storyboard?.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        self.navigationController?.pushViewController(productListViewController, animated: true)
    }
    
    func redirectToProductListVC(collectionID: String, listTitle: String?) {
        let productListViewController = storyboard?.instantiateViewController(withIdentifier: "ProductListViewController") as! ProductListViewController
        productListViewController.collectionID = collectionID
        productListViewController.listTitle = listTitle
        self.navigationController?.pushViewController(productListViewController, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return config?.homePageConfig.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let config = config?.homePageConfig {
            let configModel = config[indexPath.row]
            switch configModel.cellType {
            case "search":
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath)
                cell.selectionStyle = .none
                return cell
            case "categories":
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoriesTableViewCell", for: indexPath) as! CategoriesTableViewCell
                cell.delegate = self
                cell.setupUI()
                cell.selectionStyle = .none
                return cell
            case "multi_banner":
                let cell = tableView.dequeueReusableCell(withIdentifier: "PagerViewTableViewCell", for: indexPath) as! PagerViewTableViewCell
                cell.selectionStyle = .none
                cell.delegate = self
                cell.setupUI(pagerViews: configModel.multiBanners)
                return cell
            case "single_banner":
                let cell = tableView.dequeueReusableCell(withIdentifier: "SingleImageBannerCell", for: indexPath) as! SingleImageBannerCell
                cell.selectionStyle = .none
                cell.setupUI(banner: configModel.singleBanner)
                return cell
            case "horizontal_products":
                let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalProductTableViewCell", for: indexPath) as! HorizontalProductTableViewCell
                cell.delegate = self
                cell.setupUI(config: configModel.horizontalProductsConfig)
                cell.selectionStyle = .none
                return cell
            default:
                break
            }
        }
        return UITableViewCell(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let config = config?.homePageConfig {
            let configModel = config[indexPath.row]
            switch configModel.cellType {
            case "search":
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProductSearchViewController")
                self.navigationController?.pushViewController(vc!, animated: true)
            case "single_banner":
                if let collectionID = configModel.singleBanner?.collectionID {
                    self.redirectToProductListVC(collectionID: collectionID, listTitle: configModel.singleBanner?.title)
                }
            default:
                break
            }
        }
    }
}

extension ViewController: HorizontalProductTableViewCellDelegate {

    func didSelectAll(collectionID: String, listTitle: String?) {
        self.redirectToProductListVC(collectionID: collectionID, listTitle: listTitle)
    }
    
    func didSelectProduct(product: ProductViewModel?) {
        let productDetailViewController = storyboard?.instantiateViewController(withIdentifier: "ProductDetailViewController") as! ProductDetailViewController
        productDetailViewController.productID = product?.id ?? ""
        self.navigationController?.pushViewController(productDetailViewController, animated: true)
    }
}

extension ViewController: CategoriesTableViewCellDelegate {

    func didSelectCategory(collectionID: String, listTitle: String?) {
        self.redirectToProductListVC(collectionID: collectionID, listTitle: listTitle)
    }
}

extension ViewController: PagerViewTableViewCellDelegate {

    func pagerClickAction(collectionID: String, listTitle: String?) {
        self.redirectToProductListVC(collectionID: collectionID, listTitle: listTitle)
    }
}

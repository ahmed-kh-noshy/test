//
//  MyOrderViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 24/11/21.
//

import UIKit

class MyOrderViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var orders: PageableArray<OrderViewModel>?
    var isOrdersFetching: Bool = false
    var isAllOrdersFetched: Bool = false
    @IBOutlet weak var emptyStateView: UIView!
    var emptyStateVC: EmptyStateViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Orders"
        
        setupTableView()
        fetchOrders()
        // Do any additional setup after loading the view.
    }
    
    func fetchOrders() {
        self.isOrdersFetching = true
        Client.shared.fetchOrders(accessToken: AccountController.shared.accessToken ?? "") { orders in
            self.orders = orders
            self.tableView.reloadData()
            self.isOrdersFetching = false
            if let orders = orders, orders.items.isEmpty {
                self.emptyStateView.isHidden = false
                self.emptyStateVC?.emptyTitle = "No Orders Found"
                self.emptyStateVC?.emptyMessage = "There are no orders found"
            }
        }
    }
    
    func fetchNextOrders() {
        self.isOrdersFetching = true
        Client.shared.fetchOrders(after: orders?.items.last?.cursor, accessToken: AccountController.shared.accessToken ?? "") { orders in
            if let orders = orders {
                self.orders?.appendPage(from: orders)
                if orders.items.isEmpty {
                    self.isAllOrdersFetched = true
                }
            }
            self.tableView.reloadData()
            self.isOrdersFetching = false
        }
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MyOrderTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "MyOrderTableViewCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emptyStateSegue", let destinationVC = segue.destination as? EmptyStateViewController {
            self.emptyStateVC = destinationVC
        }
    }
}

extension MyOrderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyOrderTableViewCell", for: indexPath) as! MyOrderTableViewCell
        let item = orders?.items[indexPath.row]
        cell.setupUI(model: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = orders?.items[indexPath.row]
        if let url = item?.statusUrl {
            let webController = WebViewController(url: url, accessToken: AccountController.shared.accessToken)
            webController.navigationItem.title = title
            self.navigationController?.pushViewController(webController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let items = orders?.items, (indexPath.row == items.count - 1), !isOrdersFetching, !isAllOrdersFetched {
            self.fetchNextOrders()
        }
    }
}

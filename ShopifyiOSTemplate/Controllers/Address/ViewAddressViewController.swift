//
//  ViewAddressViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 26/11/21.
//

import UIKit
import SVProgressHUD

class ViewAddressViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var addresses: PageableArray<SavedAddressViewModel>?
    var defaultAddressID: String?
    var isAddressFetching: Bool = false
    var isAllAddressFetched: Bool = false
    @IBOutlet weak var emptyStateView: UIView!
    var emptyStateVC: EmptyStateViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Addresses"

        setupTableView()
        fetchAddresses()
        
        // Do any additional setup after loading the view.
    }
    
    func fetchAddresses() {
        self.isAddressFetching = true
        Client.shared.fetchCustomerAddresses(accessToken: AccountController.shared.accessToken ?? "") { address, defaultAddressID  in
            if let defaultAddressID = defaultAddressID {
                self.defaultAddressID = defaultAddressID
            }
            self.addresses = address
            self.tableView.reloadData()
            self.isAddressFetching = false
            if let address = address, address.items.isEmpty {
                self.emptyStateView.isHidden = false
                self.emptyStateVC?.emptyTitle = "No Address Found"
                self.emptyStateVC?.emptyMessage = "Looks like you haven't added address"
            }
        }
    }
    
    func fetchNextAddresses() {
        self.isAddressFetching = true
        Client.shared.fetchCustomerAddresses(after: addresses?.items.last?.cursor, accessToken: AccountController.shared.accessToken ?? "") { address, defaultAddressID  in
            if let defaultAddressID = defaultAddressID {
                self.defaultAddressID = defaultAddressID
            }
            if let address = address {
                self.addresses?.appendPage(from: address)
                if address.items.isEmpty {
                    self.isAllAddressFetched = true
                }
            }
            self.isAddressFetching = false
            self.tableView.reloadData()
        }
    }
    
    func resetAddress() {
        self.addresses = nil
        self.isAddressFetching = false
        self.isAllAddressFetched = false
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ViewAddressTableViewCell", bundle: nil),
                                  forCellReuseIdentifier: "ViewAddressTableViewCell")
    }
    
    @IBAction func createAddressAction(_ sender: Any) {
        let addAddressViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        addAddressViewController.delegate = self
        (self.sideMenuController?.contentViewController as? UINavigationController)?.pushViewController(addAddressViewController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "emptyStateSegue", let destinationVC = segue.destination as? EmptyStateViewController {
            self.emptyStateVC = destinationVC
        }
    }
}

extension ViewAddressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addresses?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewAddressTableViewCell", for: indexPath) as! ViewAddressTableViewCell
        let item = addresses?.items[indexPath.row]
        cell.setupUI(model: item, defaultAddressID: defaultAddressID)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let items = addresses?.items, (indexPath.row == items.count - 1), !isAddressFetching, !isAllAddressFetched {
            self.fetchNextAddresses()
        }
    }
}

extension ViewAddressViewController: ViewAddressTableViewCellDelegate {
  
    func didTapSetDefaultAddress(address: SavedAddressViewModel?) {
        guard let address = address else { return }

        Client.shared.customerDefaultAddressUpdate(address: address, accessToken: AccountController.shared.accessToken ?? "") { customerUserErrors in
            if let error = customerUserErrors.first {
                Utils.showAlertMessage(vc: self, title: "", message: error.message)
            } else {
                self.resetAddress()
                self.fetchAddresses()
            }
        }
    }
    
    func didTapEditAddress(address: SavedAddressViewModel?) {
        let addAddressViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        addAddressViewController.delegate = self
        addAddressViewController.address = address
        (self.sideMenuController?.contentViewController as? UINavigationController)?.pushViewController(addAddressViewController, animated: true)
    }
    
    func didTapDeleteAddress(address: SavedAddressViewModel?) {
        guard let address = address else { return }
        SVProgressHUD.show()
        Client.shared.customerAddressDelete(address: address, accessToken: AccountController.shared.accessToken ?? "") { customerUserErrors in
            SVProgressHUD.dismiss()
            if let error = customerUserErrors.first {
                Utils.showAlertMessage(vc: self, title: "", message: error.message)
            } else {
                self.resetAddress()
                self.fetchAddresses()
            }
        }
    }
}

extension ViewAddressViewController: AddAddressViewControllerDelegate {

    func didCreateorUpdateAddress() {
        self.resetAddress()
        self.fetchAddresses()
    }
}

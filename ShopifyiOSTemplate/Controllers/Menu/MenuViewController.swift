//
//  MenuViewController.swift
//  SideMenuExample
//
//
//  Created by Mac on 30/12/20.
//

import UIKit
import SideMenuSwift

class MenuViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var selectionTableViewHeader: UILabel!
    @IBOutlet weak var selectionMenuTrailingConstraint: NSLayoutConstraint!
    private var themeColor = UIColor.white
    var sideMenus = ["Home", "My Orders", "My Address", "Favorite Products"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMenuItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        updateSideMenu()
    }
    
    func updateSideMenu() {
        if let _ = AccountController.shared.accessToken {
            if self.sideMenus.last == "Login" {
                self.sideMenus.removeLast()
                self.sideMenus.append("Logout")
                self.tableView.reloadData()
            } else if self.sideMenus.last != "Logout" {
                self.sideMenus.append("Logout")
                self.tableView.reloadData()
            }
        } else {
            if self.sideMenus.last == "Logout" {
                self.sideMenus.removeLast()
                self.sideMenus.append("Login")
                self.tableView.reloadData()
            } else if self.sideMenus.last != "Login" {
                self.sideMenus.append("Login")
                self.tableView.reloadData()
            }
        }
    }
    
    // Parse and configure menu items
    private func configureMenuItems() {
        self.configureView()
    }
    
    private func configureView() {
        selectionMenuTrailingConstraint.constant = 0
        themeColor = .white

        let sidemenuBasicConfiguration = SideMenuController.preferences.basic
        let showPlaceTableOnLeft = (sidemenuBasicConfiguration.position == .under) != (sidemenuBasicConfiguration.direction == .right)
        if showPlaceTableOnLeft {
            selectionMenuTrailingConstraint.constant = SideMenuController.preferences.basic.menuWidth - view.frame.width
        }

        view.backgroundColor = themeColor
        tableView.backgroundColor = themeColor
    }
    
    private func redirectToLoginPage() {
        let storyboard = UIStoryboard(name: "Account", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        (self.sideMenuController?.contentViewController as? UINavigationController)?.pushViewController(loginViewController, animated: true)
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of items in the side menu view.
        return sideMenus.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SelectionCell
        cell.contentView.backgroundColor = themeColor
        // Configure the cell with the side menu item.
        cell.titleLabel?.text = sideMenus[indexPath.row]
        cell.titleLabel?.textColor = .black
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Find the corresponding side menu item.
        sideMenuController?.hideMenu(animated: true, completion: { [weak self] status in
            guard let `self` = self else { return }
            switch indexPath.row {
            case 1:
                if let _ = AccountController.shared.accessToken {
                    let myOrderViewController = self.storyboard?.instantiateViewController(withIdentifier: "MyOrderViewController")
                    (self.sideMenuController?.contentViewController as? UINavigationController)?.pushViewController(myOrderViewController!, animated: true)
                } else {
                    self.redirectToLoginPage()
                }
            case 2:
                if let _ = AccountController.shared.accessToken {
                    let viewAddressViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewAddressViewController")
                    (self.sideMenuController?.contentViewController as? UINavigationController)?.pushViewController(viewAddressViewController!, animated: true)
                } else {
                    self.redirectToLoginPage()
                }
            case 3:
                let wishListViewController = self.storyboard?.instantiateViewController(withIdentifier: "WishListViewController")
                (self.sideMenuController?.contentViewController as? UINavigationController)?.pushViewController(wishListViewController!, animated: true)
            case 4:
                if self.sideMenus.last == "Login" {
                    self.redirectToLoginPage()
                } else {
                    guard let accessToken = AccountController.shared.accessToken else {
                        return
                    }
                    
                    Client.shared.logout(accessToken: accessToken) { success in
                        if success {
                            AccountController.shared.deleteAccessToken()
                            self.updateSideMenu()
                        }
                    }
                }
            default: break
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

class SelectionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

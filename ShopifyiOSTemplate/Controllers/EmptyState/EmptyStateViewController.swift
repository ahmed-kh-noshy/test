//
//  EmptyStateViewController.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 29/11/21.
//

import UIKit

class EmptyStateViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var emptyTitle: String = "" {
        didSet {
            titleLabel?.text = emptyTitle
        }
    }
    var emptyMessage: String = "" {
        didSet {
            messageLabel?.text = emptyMessage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.text = emptyTitle
        messageLabel?.text = emptyMessage
    }
}

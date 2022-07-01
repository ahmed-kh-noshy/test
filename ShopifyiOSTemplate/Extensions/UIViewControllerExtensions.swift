//
//  UIViewControllerExtensions.swift
//  WebViewTemplate
//
//  Created by Mac on 01/01/21.
//

import UIKit

extension UIViewController {
    
    func barButtonItem(image: UIImage, tag: Int, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        button.tag = tag
        button.addTarget(self, action: action, for: .touchUpInside)
        let barButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.frame = barButtonView.bounds
        barButtonView.addSubview(button)
        let barButtonItem = UIBarButtonItem(customView: barButtonView)
        return barButtonItem
    }
    
    func setNavItemTitleImage(imageName: String) {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleAspectFit
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        self.navigationItem.titleView = titleView
    }
}

extension String {
    
    func base64Decode() -> String {
        let decodedData = Data(base64Encoded: self)!
        let decodedString = String(data: decodedData, encoding: .utf8)!
        return decodedString
    }

    func toBase64() -> String {
        return Data(utf8).base64EncodedString()
    }
}

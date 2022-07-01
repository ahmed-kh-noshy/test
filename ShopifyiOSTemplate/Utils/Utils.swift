//
//  Utils.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 21/11/21.
//

import UIKit

class Utils {

    static func showAlertMessage(vc: UIViewController, title: String, message: String, completion: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { alert in
            completion?()
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func formattedPriceString(price: Decimal, compareAtPrice: Decimal?) -> NSMutableAttributedString {
        var priceString = NSMutableAttributedString(string: "")
        if let compareAtPrice = compareAtPrice, compareAtPrice != price {
            priceString = NSMutableAttributedString(string: Currency.stringFrom(price) + " " + Currency.stringFrom(compareAtPrice))
            priceString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: (priceString.string as NSString).range(of: priceString.string))
            priceString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: (priceString.string as NSString).range(of: Currency.stringFrom(compareAtPrice)))
            priceString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: (priceString.string as NSString).range(of: Currency.stringFrom(compareAtPrice)))
        } else {
            priceString = NSMutableAttributedString(string: Currency.stringFrom(price))
            priceString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: (priceString.string as NSString).range(of: priceString.string))
        }
        return priceString
    }
}

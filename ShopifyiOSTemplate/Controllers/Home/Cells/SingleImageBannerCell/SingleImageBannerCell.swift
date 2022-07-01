//
//  SingleImageBannerCell.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 05/11/21.
//

import UIKit

class SingleImageBannerCell: UITableViewCell {

    @IBOutlet weak var bannerImageView: UIImageView!
    var banner: BannerConfig?
    
    func setupUI(banner: BannerConfig?) {
        self.banner = banner
        if let imageURL = banner?.imageURL, let url = URL(string: imageURL) {
            bannerImageView?.setImageFrom(url)
        } else if let localImageName = banner?.localImageName, let bannerImage = UIImage(named: localImageName) {
            bannerImageView?.image = bannerImage
        }
    }
}

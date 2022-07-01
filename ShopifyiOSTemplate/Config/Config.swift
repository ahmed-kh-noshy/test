//
//  Config.swift
//  ShopifyiOSTemplate
//
//  Created by Mac on 27/11/21.
//

import UIKit

struct Config: Codable {
    let homePageConfig: [HomePageConfig]
    
    enum CodingKeys: String, CodingKey {
        case homePageConfig = "home"
    }
}

struct HomePageConfig: Codable {
    let cellType: String
    let multiBanners: [BannerConfig]?
    let singleBanner: BannerConfig?
    let horizontalProductsConfig: HorizontalProductsConfig?

    enum CodingKeys: String, CodingKey {
        case cellType = "cell_type"
        case multiBanners = "banners"
        case singleBanner = "banner"
        case horizontalProductsConfig = "horizontal_products_config"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        cellType = try values.decode(String.self, forKey: .cellType)
        multiBanners = try values.decodeIfPresent([BannerConfig].self, forKey: .multiBanners)
        singleBanner = try values.decodeIfPresent(BannerConfig.self, forKey: .singleBanner)
        horizontalProductsConfig = try values.decodeIfPresent(HorizontalProductsConfig.self, forKey: .horizontalProductsConfig)
    }
}

struct BannerConfig: Codable {
    let collectionID: String?
    let imageURL: String?
    let localImageName: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case title
        case collectionID = "collection_id"
        case imageURL = "image_url"
        case localImageName = "local_image_name"
    }
}

struct HorizontalProductsConfig: Codable {
    let collectionID: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case title
        case collectionID = "collection_id"
    }
}

